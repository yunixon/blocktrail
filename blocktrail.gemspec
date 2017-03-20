# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blocktrail/version'

Gem::Specification.new do |spec|
  spec.name          = "blocktrail"
  spec.version       = Blocktrail::VERSION
  spec.authors       = ["Yuri Skurikhin"]
  spec.email         = ["yunixon@gmail.com"]

  spec.summary       = %q{Ruby bindings for the Blocktrail API.}
  spec.description   = %q{Ruby bindings for the Blocktrail API.}
  spec.homepage      = "https://github.com/yunixon/blocktrail"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client", "~> 2.0"
  spec.add_dependency "api-auth", "~> 2.1"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
