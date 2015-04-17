# -*- encoding: utf-8 -*-
require File.expand_path("../lib/tunable/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "tuktuk"
  s.version     = Tunable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Tomás Pollak']
  s.email       = ['tomas@forkhq.com']
  s.homepage    = "https://github.com/tomas/tunable"
  s.summary     = "Pluggable settings for your AR models."
  s.description = "Pluggable settings for your AR models."

  s.required_rubygems_version = ">= 1.3.6"
  # s.rubyforge_project         = "tunable"

  s.add_runtime_dependency "activerecord", "~> 4.0.0"
  s.add_runtime_dependency "activesupport", ">= 4.0.0"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", ">= 3.0.0"
  s.add_development_dependency "sqlite3", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
