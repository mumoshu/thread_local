# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'thread_local/version'

Gem::Specification.new do |spec|
  spec.name          = "thread_local"
  spec.version       = ThreadLocal::VERSION
  spec.authors       = ["Yusuke KUOKA"]
  spec.email         = ["yusuke.kuoka@crowdworks.co.jp"]
  spec.summary       = %q{An implementation of the thread-local variable.}
  spec.description   = %q{An implementation of the thread-local variable provided in many programming languages like Java.}
  spec.homepage      = "https://github.com/mumoshu/thread_local"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
