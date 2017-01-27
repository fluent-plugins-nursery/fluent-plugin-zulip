# Copyright 2017- Kenji Okimoto
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fluent/plugin/output"
require "json"
require "net/http"

module Fluent
  module Plugin
    class ZulipOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("zulip", self)

      ZULIP_SUBJECT_MAX_SIZE = 60
      ZULIP_CONTENT_MAX_SIZE = 10000

      desc "API endpoint"
      config_param :api_endpoint, :string
      desc "Bot email address"
      config_param :bot_email_address, :string
      desc "Bot API key"
      config_param :bot_api_key, :string, secret: true
      desc "Send message type"
      config_param :message_type, :enum, list: [:private, :stream], default: :stream
      desc "Target stream name"
      config_param :stream_name, :string, default: "social"
      desc "User names (email address) of the recipients for private message"
      config_param :recipients, :array, default: []
      desc "Topic subject"
      config_param :subject, :string, default: nil
      desc "Topic subject from record"
      config_param :subject_key, :string, default: nil
      desc "Content from record"
      config_param :content_key, :string, default: "message"

      def configure(conf)
        super

        case @message_type
        when :private
          raise Fluent::ConfigError, "recipients are required when private message" if @recipients.empty?
        when :stream
          raise Fluent::ConfigError, "stream_name is required when stream message" unless @stream_name
        end

        if @subject && @subject_key
          raise Fluent::ConfigError, "subject and subject_key are exclusive with each other"
        end

        if @subject && @subject.bytesize > ZULIP_SUBJECT_MAX_SIZE
          raise Fluent::ConfigError, "subject max length is #{ZULIP_SUBJECT_MAX_SIZE}"
        end

        @api_endpoint_uri = URI.parse(@api_endpoint)
      end

      def process(tag, es)
        http = Net::HTTP.new(@api_endpoint_uri.host, @api_endpoint_uri.port)
        http.use_ssl = @api_endpoint_uri.scheme == "https"
        http.start
        es.each do |time, record|
          request = build_request(tag, time, record)
          response = http.request(request)
          log.debug(response)
        end
        http.finish
      end

      def build_request(tag, time, record)
        request = Net::HTTP::Post.new(@api_endpoint_uri.path)
        request.basic_auth(@bot_email_address, @bot_api_key)
        request["Connection"] = "Keep-Alive"
        params = {
          "type" => @message_type,
          "content" => record[@content_key]
        }
        case @message_type
        when :private
          params["to"] = JSON.generate(@recipients)
        when :stream
          params["to"] = @stream_name
          params["subject"] = @subject || record[@subject_key]
        end
        request.set_form_data(params, ";")
        request
      end
    end
  end
end
