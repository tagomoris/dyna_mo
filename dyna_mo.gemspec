# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dyna_mo/version'

Gem::Specification.new do |spec|
  spec.name          = "dyna_mo"
  spec.version       = DynaMo::VERSION
  spec.authors       = ["TAGOMORI Satoshi"]
  spec.email         = ["tagomoris@gmail.com"]
  spec.summary       = %q{Testing module to provide dynamic scope method overriding}
  spec.description   = %q{Dynamic scope implementation for Method Overriding: override methods by specified context, only in current thread}
  spec.homepage      = "https://github.com/tagomoris/dyna_mo"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_development_dependency "test-unit-power_assert"
end
