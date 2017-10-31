# fluent-plugin-sakuraio

[![Build Status](https://travis-ci.org/sakuraio/fluent-plugin-sakuraio.svg?branch=master)](https://travis-ci.org/sakuraio/fluent-plugin-sakuraio)

Fluentd Input plugin to process message from [sakura.io](https://sakura.io) WebSocket API.

## Requirements

* Ruby >= 2.1
* Fluentd >= v0.14.0

## Installation

```ruby
gem install 'fluent-plugin-sakuraio'
```

## Input Configuration

```
<source>
  @type sakuraio
  url wss://api.sakura.io/ws/v1/xxxxxxxxxxxxxxxxxxxxxxx
</source>
```

### Tag format

* `channels` type messages: `{module}.channels.{channel}`
* `connection` and `location` type messages: `{module}.{type}`

### Record format

* `channels` type messages: `{"module":{module},"channel":{channel},"type":"{data type}","value":{value}}`
* `connection` type messages: `{"module":{module},"is_online":{is_online}}`
* `location` type messages: `{"module":{module},"latitude":{latitude},"longitude":"{longitude}","range_m":{range_m}}`

The details of sakura.io message spec: https://sakura.io/docs/pages/platform-specification/message.html

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

