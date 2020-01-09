# frozen_string_literal: true

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
    config_param :ping, :integer, default: 60

    def configure(conf)
      super

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
      options = {}
      @ping.positive? options[:ping] = @ping
      @client = Faye::WebSocket::Client.new(@url, nil, options)
      EM.next_tick do
        @client.on :open do
          log.info "sakuraio: starting websocket connection for #{@url}."
        end

        @client.on :message do |event|
          log.debug "sakuraio: received message #{event.data}"
        end

        @client.on :error do |event|
          log.warn "sakuraio: #{event.message}"
        end

        @client.on :close do |event|
          log.warn "sakuraio: #{event.code} #{event.reason}"
          run
        end
      end
    end

    def process(_tag, events)
      events.each do |_time, record|
        log.debug "sakuraio: process record #{record}"
        modules.each do |m|
          s = encode_record(m, record)
          log.debug "sakuraio: encoded json #{s}"
          @client.send(s)
        end
      end
    end

    def encode_record(mod, record)
      data = []
      @channels.each do |ch, v|
        key, type = v
        data.push('channel' => ch.to_i,
                  'type' => type,
                  'value' => record[key])
      end
      hash = { 'type' => 'channels',
               'module' => mod,
               'payload' => { 'channels' => data } }
      Yajl::Encoder.encode(hash)
    end
  end
end
