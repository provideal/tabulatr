# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tabulatr/version"

Gem::Specification.new do |s|
  s.name        = "tabulatr"
  s.version     = Tabulatr::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = "A tight DSL to build tables of ActiveRecord or Mongoid models with sorting, pagination, finding/filtering, selecting and batch actions."
  s.email       = "info@provideal.net"
  s.homepage    = "http://github.com/provideal/tabulatr"
  s.description = "A tight DSL to build tables of ActiveRecord or Mongoid models with sorting, pagination, finding/filtering, selecting and batch actions. " +
                  "Tries to do for tables what formtastic and simple_form did for forms."
  s.authors     = ['Peter Horn', 'René Sprotte']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.rdoc_options  = ['--charset=UTF-8']
  

  s.add_runtime_dependency('rails', '>= 3.0.0')
  s.add_dependency('whiny_hash', '>= 0.0.2')
  s.add_dependency('id_stuffer', '>= 0.0.1')
end
