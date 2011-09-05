# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "clinical_trials/version"

Gem::Specification.new do |s|
  s.name        = "clinical_trials"
  s.version     = ClinicalTrials::VERSION
  s.authors     = ["Graeme Worthy"]
  s.email       = ["graemeworthy@gmail.com"]
  s.homepage    = "https://github.com/feldpost/clinical_trials"
  s.summary     = %q{An importer for clinical trials from http://clinicaltrials.gov}
  s.description = %q{An importer for clinical trials from http://clinicaltrials.gov written by Graeme Worthy}

  s.rubyforge_project = "clinical_trials"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_runtime_dependency  ['nokogiri']
end
