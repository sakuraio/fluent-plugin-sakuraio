require 'faye/websocket'
require 'time'

KEEPALIVE_MESSAGE = '{"type":"keepalive","datetime":"2017-10-30T05:14:03.374887685Z"}'.freeze

CONNECTION_MESSAGE = '{
    "module": "uXXXXXXXXXXX",
    "type": "connection",
    "datetime": "2017-04-06T07:39:29.703232943Z",
    "payload": {
        "is_online": true
    }
}'.freeze

LOCATION_MESSAGE = '{
    "datetime": "2017-04-04T01:31:19.6431197Z",
    "module": "uXXXXXXXXXXX",
    "type": "location",
    "payload": {
        "coordinate": {
            "latitude": 34.704254,
            "longitude": 135.494691,
            "range_m": 0
        }
    }
}'.freeze

CHANNELS_MESSAGE = '{
    "module": "uXXXXXXXXXXX",
    "type": "channels",
    "datetime": "2017-04-06T07:46:36.005341001Z",
    "payload": {
        "channels": [{
            "channel": 0,
            "type": "I",
            "value": 10,
            "datetime": "2017-04-06T07:39:29.703232943Z"
        }, {
            "channel": 1,
            "type": "L",
            "value": 100,
            "datetime": "2017-04-06T07:39:30.703232943Z"
        }]
    }
}'.freeze

Faye::WebSocket.load_adapter('thin')
Thin::Logging.silent = true

class TestServer
  def call(env)
    ws = Faye::WebSocket.new(env)
    ws.on :open do
      ws.send(KEEPALIVE_MESSAGE)
      ws.send(CONNECTION_MESSAGE)
      ws.send(LOCATION_MESSAGE)
      ws.send(CHANNELS_MESSAGE)
    end
    ws.rack_response
  end

  def listen(host = '127.0.0.1', port = 8080)
    Rack::Handler.get('thin').run(self, Host: host, Port: port) do |s|
      @server = s
    end
  end

  def stop
    @server.stop
  end
end
