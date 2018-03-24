
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'builder_support/version'

Gem::Specification.new do |spec|
  spec.name          = 'builder_support'
  spec.version       = BuilderSupport::VERSION
  spec.authors       = ['zhandao']
  spec.email         = ['x@skippingcat.com']

  spec.summary       = 'Provide a very simple way to transform ActiveRecord data into JSON output based on JBuilder.'
  spec.description   = 'Provide a very simple way to transform ActiveRecord data into JSON output based on JBuilder.'
  spec.homepage      = 'https://github.com/ikkiuchi/builder_support'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'

  spec.add_runtime_dependency 'activerecord', '>= 3'
end
