require 'helper'
require 'fluent/plugin/in_sakuraio'
require 'fluent/test/driver/input'

class SakuraIOInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %([
    url URL
  ]).freeze

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::SakuraIOInput).configure(conf)
  end

  sub_test_case 'config' do
    test 'check url' do
      d = create_driver
      assert_equal 'URL', d.instance.url
    end
  end

  expected_records = [
    [
      'uXXXXXXXXXXX.0',
      Time.parse('2017-04-06T07:39:29.703232943Z').to_i,
      { 'channel' => 0, 'type' => 'I', 'value' => 10 }
    ],
    [
      'uXXXXXXXXXXX.1',
      Time.parse('2017-04-06T07:39:30.703232943Z').to_i,
      { 'channel' => 1, 'type' => 'L', 'value' => 100 }
    ]
  ]

  sub_test_case 'emit' do
    test 'test expects plugin emits events 2 times' do
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

      d.run(expect_emits: 2, timeout: 10)
      expected_records.zip(d.events) do |a|
        assert_equal a[0], a[1]
      end
      t.kill
    end
  end
end
