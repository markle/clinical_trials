# --- 
#imedris_file: https://research.scripps.org/imedris_clinical_trials.txt
#nct_file:     https://research.scripps.org/imedris_nct.txt

module ClinicalTrials
  class Configuration
    attr_accessor :imedris_file, :nct_file
    
    DEFAULTS = {
      'imedris_file' => "https://research.scripps.org/imedris_clinical_trials.txt",
      'nct_file'    => "https://research.scripps.org/imedris_nct.txt",
    }
    
    def initialize(options={})
      DEFAULTS.each do |key,value|
        self.send("#{key}=", options[key] || value)
      end
    end
    
    def reset!
      DEFAULTS.each do |key,value|
        self.send("#{key}=", value)
      end
    end
    
  end

  class << self
    attr_accessor :configuration
  end

  # configuration usage
  # @example
  #   ClinicalTrials.configure do |config|
  #     config.imedris_file     = 'http://someplace_it_moved_to.html'
  #     config.nct_file         = 'a_test_file.txt'
  #   end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end