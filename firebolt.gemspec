# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'firebolt/version'

Gem::Specification.new do |spec|
  spec.name          = "firebolt"
  spec.version       = Firebolt::VERSION
  spec.authors       = ["Adam Hutchison","BJ Neilsen"]
  spec.email         = ["liveh2o@gmail.com","bj.neilsen@gmail.com"]
  spec.description   = %q{Simple little cache warmer.}
  spec.summary       = %q{Firebolt is a simple cache warmer. It warms the cache using a specially defined warmer class.}
  spec.homepage      = "https://github.com/moneydesktop/firebolt"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  ##
  # Dependencies
  #
  spec.add_dependency "json"
  spec.add_dependency "rufus-scheduler", "~> 3.0"
  spec.add_dependency "concurrent-ruby", "~> 1.0"
  spec.add_dependency "activesupport"

  ##
  # Development Dependencies
  #
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
