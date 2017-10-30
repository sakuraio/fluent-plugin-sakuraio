# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'fluent-plugin-sakuraio'
  spec.version       = '0.0.2'
  spec.authors       = ['Yuya Kusakabe']
  spec.email         = ['yuya.kusakabe@gmail.com']

  spec.summary       = 'fluentd plugin for sakura.io'
  spec.description   = 'fluentd plugin for sakura.io'
  spec.homepage      = 'https://github.com/higebu/fluent-plugin-sakuraio'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1'

  spec.add_runtime_dependency 'eventmachine'
  spec.add_runtime_dependency 'faye-websocket'
  spec.add_runtime_dependency 'fluentd'
  spec.add_runtime_dependency 'yajl-ruby'
  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'test-unit'
  spec.add_development_dependency 'rack'
  spec.add_development_dependency 'thin'
end
