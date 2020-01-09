# frozen_string_literal: true

require 'fluent/plugin/input'
require 'yajl'
require 'faye/websocket'
require 'eventmachine'

module Fluent::Plugin
  class SakuraIOInput < Input
    Fluent::Plugin.register_input('sakuraio', self)

    helpers :thread

    config_param :url, :string, secret: true
    config_param :ping, :integer, default: 60

    def configure(conf)
      super

      @time_parser = Fluent::TimeParser.new(nil)
    end

    def start
      super

      ensure_reactor_running
      thread_create(:in_sakuraio, &method(:run))
    end

    def ensure_reactor_running
      return if EM.reactor_running?

      thread_create(:in_sakuraio_reactor) do
        EM.run
      end
    end

    def shutdown
      EM.stop if EM.reactor_running?

      super
    end

    def run
      options = {}
      @ping.positive? options[:ping] = @ping
      client = Faye::WebSocket::Client.new(@url, nil, options)
      EM.next_tick do
        client.on :open do
          log.info "sakuraio: starting websocket connection for #{@url}."
        end

        client.on :message do |event|
          handle_message(event)
        end

        client.on :error do |event|
          log.warn "sakuraio: #{event.message}"
        end

        client.on :close do |event|
          log.warn "sakuraio: #{event.code} #{event.reason}"
          run
        end
      end
    end

    def handle_message(event)
      log.debug "sakuraio: received message #{event.data}"
      records = parse(event.data)
      return if records.empty?

      records.each do |r|
        router.emit(r['tag'], r['time'], r['record'])
      end
    end

    def parse(text)
      parser = Yajl::Parser.new
      j = parser.parse(text)
      records = []
      case j['type']
      when 'connection'
        parse_connection(records, j)
      when 'location'
        parse_location(records, j)
      when 'channels'
        parse_channels(records, j)
      else
        log.debug "unknown type: #{j['type']}: #{text}"
      end
      records
    end

    def parse_connection(records, data)
      record = {
        'tag' => data['module'] + '.connection',
        'record' => {
          'module' => data['module'],
          'is_online' => data['payload']['is_online']
        },
        'time' => @time_parser.parse(data['datetime'])
      }
      records.push(record)
      records
    end

    def parse_location(records, data)
      c = data['payload']['coordinate']
      if c != 'null'
        record = {
          'tag' => data['module'] + '.location',
          'record' => {
            'module' => data['module'],
            'latitude' => c['latitude'],
            'longitude' => c['longitude'],
            'range_m' => c['range_m']
          },
          'time' => @time_parser.parse(data['datetime'])
        }
        records.push(record)
      end
      records
    end

    def parse_channels(records, data)
      msg_time = @time_parser.parse(data['datetime'])
      mod = data['module']
      data['payload']['channels'].each do |c|
        records.push(parse_channel(mod, msg_time, c))
      end
      records
    end

    def parse_channel(mod, msg_time, chan)
      {
        'tag' => mod + '.channels.' + chan['channel'].to_s,
        'record' => {
          'module' => mod,
          'channel' => chan['channel'],
          'type' => chan['type'],
          'value' => chan['value']
        },
        'time' => @time_parser.parse(chan['datetime']) || msg_time
      }
    end
  end
end
