require 'open-uri'
require 'yaml'
require 'csv'
require 'iconv'

require "clinical_trials/version"
require 'clinical_trials/assembler'
require 'clinical_trials/scraper'
require 'clinical_trials/parser'
require 'clinical_trials/update'
require 'clinical_trials/eligibility_cleaner'
require 'clinical_trials/pretty_printer'
require 'clinical_trials/scripps_lists'
require 'clinical_trials/scripps_trials'

module ClinicalTrials
  class << self; end;
end