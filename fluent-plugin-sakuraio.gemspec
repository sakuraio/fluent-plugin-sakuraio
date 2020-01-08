# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'fluent-plugin-sakuraio'
  spec.version       = '0.1.3'
  spec.authors       = ['Yuya Kusakabe']
  spec.email         = ['yuya.kusakabe@gmail.com']

  spec.summary       = 'fluentd plugin for sakura.io'
  spec.description   = 'fluentd plugin for sakura.io'
  spec.homepage      = 'https://github.com/sakuraio/fluent-plugin-sakuraio'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  spec.add_runtime_dependency 'eventmachine'
  spec.add_runtime_dependency 'faye-websocket'
  spec.add_runtime_dependency 'fluentd', '>= 0.14', '< 2'
  spec.add_runtime_dependency 'yajl-ruby'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'codecov'
  spec.add_development_dependency 'rack'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'test-unit'
  spec.add_development_dependency 'thin'
end
