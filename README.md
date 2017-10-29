# fluent-plugin-sakuraio

Fluentd Input plugin to process message from sakura.io websocket API.

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

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

