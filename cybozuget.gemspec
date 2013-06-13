# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cybozuget/version'

Gem::Specification.new do |spec|
  spec.name          = "cybozuget"
  spec.version       = CybozuGet::VERSION
  spec.authors       = ["hiro-su"]
  spec.email         = ["h.sugipon@gmail.com"]
  spec.description   = %q{cybozu garoon schedule get}
  spec.summary       = %q{cybozu garoon schedule get}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
