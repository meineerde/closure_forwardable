# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'closure_forwardable/version'

Gem::Specification.new do |spec|
  spec.name          = 'closure_forwardable'
  spec.version       = ClosureForwardable::VERSION
  spec.authors       = ['Holger Just']
  spec.email         = ['hello@holgerjust.de']

  spec.summary       = <<-EOF.gsub(/^\s+/, '').gsub(/\s*\n/, ' ').strip
    A variant of the Forwardable module in the Ruby Standards Library. Instead
    of requiring the delegation object to be available on the class, it can
    be any object.
  EOF
  spec.homepage      = 'https://github.com/meineerde/closure_forwardable'
  spec.license       = 'MIT'

  files = `git ls-files -z`.split("\x0")
  spec.files = files.reject { |f| f.match(%r{^(test|spec|feature)/}) }
  spec.bindir = 'exe'
  spec.executables = files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10' # license: MIT
  spec.add_development_dependency 'rake', '~> 10.0' # license: MIT
  spec.add_development_dependency 'rspec', '~> 3.2' # license: MIT
  spec.add_development_dependency 'rubocop', '~> 0.32' # license: MIT
  spec.add_development_dependency 'yard', '~> 0.8.6' # license: MIT
end
