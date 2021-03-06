# frozen_string_literal: true

require 'helper'
require 'fluent/plugin/in_sakuraio'
require 'fluent/test/driver/input'

class SakuraIOInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
    @time_parser = Fluent::TimeParser.new(nil)
  end

  CONFIG = %([
    url URL
  ])

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::SakuraIOInput).configure(conf)
  end

  sub_test_case 'config' do
    test 'check url' do
      d = create_driver
      assert_equal 'URL', d.instance.url
    end
  end

  sub_test_case 'emit' do
    test 'test expects plugin emits events 4 times' do
      expected_records = [
        [
          'uXXXXXXXXXXX.connection',
          @time_parser.parse('2017-04-06T07:39:29.703232943Z'),
          { 'module' => 'uXXXXXXXXXXX', 'is_online' => true }
        ],
        [
          'uXXXXXXXXXXX.location',
          @time_parser.parse('2017-04-04T01:31:19.6431197Z'),
          { 'module' => 'uXXXXXXXXXXX', 'latitude' => 34.704254, 'longitude' => 135.494691, 'range_m' => 0 }
        ],
        [
          'uXXXXXXXXXXX.channels.0',
          @time_parser.parse('2017-04-06T07:39:29.703232943Z'),
          { 'module' => 'uXXXXXXXXXXX', 'channel' => 0, 'type' => 'I', 'value' => 10 }
        ],
        [
          'uXXXXXXXXXXX.channels.1',
          @time_parser.parse('2017-04-06T07:39:30.703232943Z'),
          { 'module' => 'uXXXXXXXXXXX', 'channel' => 1, 'type' => 'L', 'value' => 100 }
        ]
      ]

      test_server = TestServer.new
      t = Thread.new do
        test_server.listen('127.0.0.1', 8080)
      end
      c = %([
        url ws://127.0.0.1:8080
      ])
      sleep 0.1
      d = create_driver(c)

      assert_equal 'ws://127.0.0.1:8080', d.instance.url

      d.run(expect_emits: 4, timeout: 10)
      expected_records.zip(d.events) do |a|
        assert_equal a[0], a[1]
      end
      t.kill
    end
  end
end
