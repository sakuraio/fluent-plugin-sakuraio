# frozen_string_literal: true

require 'helper'
require 'fluent/plugin/out_sakuraio'
require 'fluent/test/driver/output'

class SakuraIOOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
    @time_parser = Fluent::TimeParser.new(nil)
  end

  CONFIG = %([
    url URL
    modules ["AAA","BBB","CCC"]
    channels {"0": ["KEY", "TYPE"]}
  ])

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::SakuraIOOutput).configure(conf)
  end

  sub_test_case 'config' do
    test 'check url' do
      d = create_driver
      assert_equal 'URL', d.instance.url
    end
    test 'check modules' do
      d = create_driver
      assert_equal %w[AAA BBB CCC], d.instance.modules
    end
    test 'check channels' do
      d = create_driver
      assert_equal({ '0' => %w[KEY TYPE] }, d.instance.channels)
    end
  end

  sub_test_case 'tests for #process' do
    test 'test #process' do
      test_server = TestServer.new
      t = Thread.new do
        test_server.listen('127.0.0.1', 8081)
      end
      c = %([
        url ws://127.0.0.1:8081
        modules ["uXXXXXXXXXXX"]
        channels {"0": ["KEY", "i"]}
      ])
      sleep 0.1
      d = create_driver(c)
      assert_equal 'ws://127.0.0.1:8081', d.instance.url
      sleep 0.1

      t = @time_parser.parse('2016-06-10 19:46:32 +0900')
      d.run do
        d.feed('tag', t, 'KEY' => 1)
      end
      sleep 1
      assert_equal '{"type":"channels","module":"uXXXXXXXXXXX","payload":{"channels":[{"channel":0,"type":"i","value":1}]}}', test_server.data
    end
  end
end
