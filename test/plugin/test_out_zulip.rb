require "helper"
require "fluent/plugin/out_zulip.rb"

class ZulipOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::ZulipOutput).configure(conf)
  end

  CONF = config_element("ROOT", "", {
                          "api_endpoint" => "https://zulip.example.com/api/v1/messages",
                          "bot_email_address" => "example-bot@example.com",
                          "bot_api_key" => "very-secret-value",
                        })

  sub_test_case "configure" do
    test "empty" do
      assert_raise(Fluent::ConfigError) do
        create_driver(config_element("", {}))
      end
    end

    test "minimal" do
      d = create_driver(CONF)
      actual = {
        api_endpoint: d.instance.api_endpoint,
        bot_email_address: d.instance.bot_email_address,
        bot_api_key: d.instance.bot_api_key
      }
      expected = {
        api_endpoint: "https://zulip.example.com/api/v1/messages",
        bot_email_address: "example-bot@example.com",
        bot_api_key: "very-secret-value",
      }
      assert_equal(expected, actual)
    end

    test "no recipients when message_type is private" do
      conf = CONF + config_element("", "", { "message_type" => :private })
      assert_raise(Fluent::ConfigError.new("recipients are required when private message")) do
        create_driver(conf)
      end
    end

    test "specify both subject and subject_key" do
      conf = CONF + config_element("", "", { "subject" => "test", "subject_key" => "subject" })
      assert_raise(Fluent::ConfigError.new("subject and subject_key are exclusive with each other")) do
        create_driver(conf)
      end
    end

    test "subject is too long" do
      conf = CONF + config_element("", "", { "subject" => "x" * 61 })
      assert_raise(Fluent::ConfigError.new("subject max length is 60")) do
        create_driver(conf)
      end
    end
  end

  sub_test_case "process" do
    test "simple" do
      d = create_driver(CONF)
      record = { message: "This is test message" }
      headers = {
        "Connection" => "Keep-Alive",
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Content-Type" => "application/x-www-form-urlencoded",
        "User-Agent" => "Ruby"
      }
      stub_request(:post, "https://zulip.example.com/api/v1/messages")
        .with(basic_auth: ["example-bot@example.com", "very-secret-value"],
              headers: headers,
              body: "type=stream;content;to=social;subject")
        .to_return(headers: {},
                   body: { message: "", result: "success", id: 1234 }.to_json)
      d.run(default_tag: "test") do
        d.feed(event_time, record)
      end
      line = d.logs.first
      message = line[/(\[info\]: \{.+\})/, 1]
      assert_equal(%q([info]: {"message":"","result":"success","id":1234}), message)
    end

    test "http error" do
      d = create_driver(CONF)
      record = { message: "This is test message" }
      headers = {
        "Connection" => "Keep-Alive",
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Content-Type" => "application/x-www-form-urlencoded",
        "User-Agent" => "Ruby"
      }
      stub_request(:post, "https://zulip.example.com/api/v1/messages")
        .with(basic_auth: ["example-bot@example.com", "very-secret-value"],
              headers: headers,
              body: "type=stream;content;to=social;subject")
        .to_return(status: 500,
                   headers: {},
                   body: { message: "", result: "failure" }.to_json)
      d.run(default_tag: "test") do
        d.feed(event_time, record)
      end
      line = d.logs.first
      message = line[/(\[error\]:  status=.+ body=.+)/, 1]
      assert_equal(%q([error]:  status="500" body="{\\"message\\":\\"\\",\\"result\\":\\"failure\\"}"), message)
    end
  end
end
