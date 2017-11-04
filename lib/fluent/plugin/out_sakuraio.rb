require 'fluent/plugin/output'
require 'yajl'
require 'faye/websocket'

module Fluent::Plugin
  class SakuraIOOutput < Output
    Fluent::Plugin.register_output('sakuraio', self)

    config_param :url, :string, secret: true
    config_param :modules, :array, value_type: :string, secret: true
    # channels {"channel_number": ["key", "type"]}
    config_param :channels, :hash

    def configure(conf)
      super

      @client = Faye::WebSocket::Client.new(@url)
      ensure_reactor_running
      thread_create(:out_sakuraio, &method(:run))
    end

    def ensure_reactor_running
      return if EM.reactor_running?
      thread_create(:out_sakuraio_reactor) do
        EM.run
      end
    end

    def run
      EM.next_tick do
        @client.on :open do
          log.info "sakuraio: starting websocket connection for #{@url}."
        end

        @client.on :error do |event|
          log.warn "sakuraio: #{event.message}"
        end

        @client.on :close do
          @client = nil
        end
      end
    end

    def process(_tag, es)
      es.each do |_time, record|
        log.debug "sakuraio: process record #{record}"
        @client.send(encode_record(record))
      end
    end

    def encode_record(record)
      data = []
      @channels.each do |ch, v|
        key, type = v
        data.push('channel' => ch,
                  'type' => type,
                  'value' => record[key])
      end
      hash = { 'type' => 'channels',
               'payload' => { 'channels' => data } }
      Yajl::Encoder.encode(hash)
    end
  end
end
