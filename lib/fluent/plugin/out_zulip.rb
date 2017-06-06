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
require "zulip/client"

module Fluent
  module Plugin
    class ZulipOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("zulip", self)

      ZULIP_SUBJECT_MAX_SIZE = 60
      ZULIP_CONTENT_MAX_SIZE = 10000

      desc "Site URI. ex: https://zulip.exmaple.com/"
      config_param :site, :string
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
      config_param :verify_ssl, :bool, default: true

      config_section :buffer do
        config_set_default :chunk_keys, ["tag"]
      end

      def multi_workers_ready?
        true
      end

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

        @client = Zulip::Client.new(site: @site,
                                    username: @bot_email_address,
                                    api_key: @bot_api_key,
                                    ssl: { verify: @verify_ssl })
      end

      def process(tag, es)
        es.each do |time, record|
          loop do
            response = send_message(tag, time, record)
            case
            when response.success?
              log.trace(response.body)
            when response.status == 429
              interval = response.headers["X-RateLimit-Reset"].to_i - Time.now.to_i
              log.info("Sleeping: #{interval} sec")
              sleep(interval)
              next
            else
              log.error(status: response.status,
                        message: response.reason_phrase,
                        body: response.body)
            end
            log.debug(response)
            break
          end
        end
      end

      def write(chunk)
        tag = chunk.metadata.tag
        chunk.each do |time, record|
          loop do
            response = send_message(tag, time, record)
            case
            when response.success?
              log.trace(response.body)
            when response.status == 429
              interval = response.headers["X-RateLimit-Reset"].to_i - Time.now.to_i
              log.info("Sleeping: #{interval} sec")
              sleep(interval)
              next
            else
              log.error(status: response.status,
                        message: response.reason_phrase,
                        body: response.body)
            end
            log.debug(response)
            break
          end
        end
      end

      def send_message(tag, time, record)
        case @message_type
        when :stream
          to = @stream_name
          subject = @subject || record[@subject_key]
          @client.send_public_message(to: to,
                                      subject: subject,
                                      content: record[@content_key])
        when :private
          to = @recipients
          @client.send_private_message(to: to,
                                       content: record[@content_key])
        end
      end
    end
  end
end
