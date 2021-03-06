# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attention/version'

Gem::Specification.new do |spec|
  spec.name          = 'attention'
  spec.version       = Attention::VERSION
  spec.authors       = ['Michael Parrish']
  spec.email         = ['michael@zooniverse.org']

  spec.summary       = 'Redis-based server awareness'
  spec.description   = 'Redis-based server awareness for distributed applications'
  spec.homepage      = 'https://github.com/parrish/attention'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'concurrent-ruby', '~> 1.0.2'
  spec.add_runtime_dependency 'concurrent-ruby-ext', '~> 1.0.2'
  spec.add_runtime_dependency 'redis', '~> 3'
  spec.add_runtime_dependency 'redis-namespace', '~> 1.5'
  spec.add_runtime_dependency 'connection_pool', '~> 2'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'guard-rspec', '~> 4.5'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'codeclimate-test-reporter'
end
