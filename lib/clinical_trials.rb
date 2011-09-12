require 'open-uri'
require 'yaml'
require 'csv'
require 'iconv'
require 'nokogiri'

require "clinical_trials/version" 
require "clinical_trials/configuration"
require 'clinical_trials/merger'
require 'clinical_trials/assembler'
require 'clinical_trials/assemblage'
require 'clinical_trials/scraper'
require 'clinical_trials/parser'
require 'clinical_trials/update'
require 'clinical_trials/eligibility_cleaner'
require 'clinical_trials/pretty_printer'
require 'clinical_trials/list'
require 'clinical_trials/lists/imedris_list'
require 'clinical_trials/lists/nct_list'
require 'clinical_trials/trial'
require 'clinical_trials/trials/imedris_trial'
require 'clinical_trials/trials/nct_trial'

module ClinicalTrials
  class << self; end;
end