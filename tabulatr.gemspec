# coding: utf-8

#require File.expand_path('../lib/tabulatr/version', __FILE__)

Gem::Specification.new do |s|
  s.add_runtime_dependency('rails', '~> 3.0.3')

  s.authors = ["René Sprotte", "Dr. Peter Horn"]
  s.description = %q{tabulatr is a tool to auto create tables for admin backends}
  s.email = ['team@metaminded.com']
  #s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  #s.extra_rdoc_files = ['README.mkd']
  s.files = `git ls-files`.split("\n")
  s.homepage = 'http://github.com/provideal/tabulatr'
  s.name = 'tabulatr'
  s.platform = Gem::Platform::RUBY
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.6') if s.respond_to? :required_rubygems_version=
  s.rubyforge_project = 'tabulatr'
  s.summary = %q{Tables for Rails Backends}
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = "0.0.1" # MmCms::VERSION
  s.add_dependency('whiny_hash', '>= 0.0.2')
end