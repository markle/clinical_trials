module ClinicalTrials
  class Assemblage
    
    attr_accessor :nct_trial, :imedris_trial, :clinical_trial
    
    def initialize(nct = nil, imedris = nil)
      @nct_trial = nct
      @imedris_trial = imedris     
      @clinical_trial = nil
    end

    def trial_number    
      return nil unless @nct_trial
      @trial_number = @nct_trial.nct_num
      return nil unless ClinicalTrials::Trials::NctTrial.check_format(@trial_number)
      @trial_number
    end

    def irb_number
      @irb_number = merged_fields['irb_number']
      @irb_number
    end


    def clinical_trials_dot_gov
      # puts "dot gov #{trial_number}"
      return nil unless trial_number
      # puts "fetching trial_number"
      @clinical_trial ||= Parser.new(clinical_trials_dot_gov_xml)
    end

    ## this actually makes a web call to clinicaltrials.gov
    def clinical_trials_dot_gov_xml
      @clinical_trials_dot_gov_xml ||= XmlScraper.fetch_by_nct(trial_number)
    end

    def merged_fields
      #order of operations
      #Imedris, is most cannonical
      #Nct, is second most
      #ClinicalTrials.gov is third most
      @merged ||= ClinicalTrials::Merger.new([@imedris_trial, @nct_trial, @clinical_trial])
      @merged.to_hash
    end

  end
end
