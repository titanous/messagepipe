# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'messagepipe/version'

Gem::Specification.new do |s|
  s.name        = 'messagepipe'
  s.version     = MessagePipe::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Tobias Lütke']
  s.email       = ['tobi@shopify.com']
  s.homepage    = 'http://github.com/tobi/messagepipe'
  s.summary     = %q{MessagePack based high performance RPC layer}
  s.description = %q{MessagePack based high performance RPC layer}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'eventmachine', '>= 0.12.10'
  s.add_dependency 'msgpack',      '>= 0.4.4'
end
