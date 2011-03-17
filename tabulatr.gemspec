# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tabulatr/version"

Gem::Specification.new do |s|
  s.name        = "tabulatr"
  s.version     = Tabulatr::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Tabulatr is a DSL to easily create tables for e.g. admin backends."
  s.email       = "info@provideal.net"
  s.homepage    = "http://github.com/provideal/tabulatr"
  s.description = "Tabulatr enables you to create fancy tables with filtering, pagination, " +
                  "batch action, bells, AND whistles. You do this mainly by specifying the " +
                  "names of the columns. See the README for details."
  s.authors     = ['Peter Horn', 'René Sprotte']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = []
  s.require_paths = ["lib"]
  s.rdoc_options  = ['--charset=UTF-8']
  

  s.add_runtime_dependency('rails', '~> 3.0')
  s.add_dependency('whiny_hash', '>= 0.0.2')
  s.add_dependency('id_stuffer', '>= 0.0.1')

  s.rubyforge_project = "tabulatr"
end
