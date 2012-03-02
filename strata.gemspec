# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "strata/version"

Gem::Specification.new do |s|
  s.name        = "strata"
  s.version     = Strata::VERSION
  s.authors     = ["Douglas Anderson", "Jeffrey van Aswegen"]
  s.email       = ["i.am.douglas.anderson@gmail.com, jeffmess@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A gem for manipulating string-based records.}
  s.description = %q{A gem for manipulating string-based records.}

  s.rubyforge_project = "strata"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "activesupport"
  s.add_dependency "i18n"
end
