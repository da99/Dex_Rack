# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "Dex_Rack/version"

Gem::Specification.new do |s|
  s.name        = "Dex_Rack"
  s.version     = Dex_Rack::VERSION
  s.authors     = ["da99"]
  s.email       = ["i-hate-spam-45671204@mailinator.com"]
  s.homepage    = "https://github.com/da99/Dex_Rack"
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'bacon'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'Bacon_Colored'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rack-test'
  
  # Specify any dependencies here; for example:
  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'markaby'
  s.add_runtime_dependency 'thin'
  s.add_runtime_dependency 'sinatra-reloader'
  s.add_runtime_dependency 'chronic_duration'
end
