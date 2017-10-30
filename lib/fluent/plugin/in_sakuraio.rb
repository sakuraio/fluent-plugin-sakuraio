require 'fluent/input'
require 'yajl'
require 'faye/websocket'
require 'eventmachine'
require 'time'

module Fluent::Plugin
  class SakuraIOInput < Input
    Fluent::Plugin.register_input('sakuraio', self)

    helpers :thread

    config_param :url, :string, default: nil

    def configure(conf)
      super

    end

    def start
      super

      thread_create(:in_sakuraio) do
        run
      end
    end

    def shutdown
      super
    end

    def run
      EM.run do
        client = Faye::WebSocket::Client.new(@url)
        client.on :open do
          log.info "sakuraio: starting websocket connection for #{@url}."
        end

        client.on :message do |event|
          log.debug "sakuraio: received message #{event.data}"
          records = parse(event.data)
          unless records.empty?
            records.each do |r|
              router.emit(r['tag'], r['time'], r['record'])
            end
          end
        end

        client.on :error do |event|
          log.warn "sakuraio: #{event.message}"
        end

        client.on :close do
          client = nil
        end
      end
    end

    def parse(text)
      parser = Yajl::Parser.new
      j = parser.parse(text)
      records = []
      case j['type']
      when 'connection' then
        parse_connection(records, j)
      when 'location' then
        parse_location(records, j)
      when 'channels' then
        parse_channels(records, j)
      else
        log.debug "unknown type: #{j['type']}: #{text}"
      end
      records
    end

    def parse_connection(records, j)
      record = {
        'tag' => j['module'] + '.connection',
        'record' => {
          'is_online' => j['payload']['is_online']
        },
        'time' => Time.parse(j['datetime']).to_i
      }
      records.push(record)
      records
    end

    def parse_location(records, j)
      c = j['payload']['coordinate']
      if c != 'null'
        record = {
          'tag' => j['module'] + '.location',
          'record' => {
            'latitude' => c['latitude'],
            'longitude' => c['longitude'],
            'range_m' => c['range_m']
          },
          'time' => Time.parse(j['datetime']).to_i
        }
        records.push(record)
      end
      records
    end

    def parse_channels(records, j)
      message_time = Time.parse(j['datetime']).to_i
      tag = j['module']
      j['payload']['channels'].each do |c|
        record = {
          'tag' => tag + '.channels.' + c['channel'].to_s,
          'record' => {
            'channel' => c['channel'],
            'type' => c['type'],
            'value' => c['value']
          },
          'time' => Time.parse(c['datetime']).to_i || message_time
        }
        records.push(record)
      end
      records
    end
  end
end
