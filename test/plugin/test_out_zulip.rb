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
end
