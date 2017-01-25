require "helper"
require "fluent/plugin/out_zulip.rb"

class ZulipOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::ZulipOutput).configure(conf)
  end

  def test_failure
    flunk
  end
end
