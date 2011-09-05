#just a container for the data from the scripps getter 
module ClinicalTrials
  class Trial
    def initialize(trial = {})
      @trial = trial
      clean if @trial['nct_num']
    end
    def clean
      if nct_num != nil
        nct_num.gsub!(/[^A-Za-z0-9]/, "")
        nct_num.strip!
      end
    end
    def dump
      @trial
    end
    alias to_hash dump

    def self.check_format(nct_num)
      !! "#{nct_num}".match(/^NCT\d{2,}/)
    end  
    def map_research_type
       return unless research_type
       types = research_type.split("|")
       types.collect! {|type| research_type_mappings[type] || type}
       types.join 
    end
    def research_type_mappings
      {
        "Oncology and Hematology" => "Cancer",
        "Hematology and Oncology" => "Cancer"
      }
    end
  end

  class ScrippsNctTrial < Trial
    @fields = %w(irb_number study_title pi_name research_type nct_num enrolling) 
    @fields.each do |i|
      define_method("#{i}") do
         @trial[i]
      end
      define_method("#{i}=") do |value|
         @trial[i] = value
      end
    end
    def self.fields
      @fields
    end
    def to_hash
      hash = @trial.dup()
      hash['title'] = hash.delete('study_title')
      hash['investigator'] = hash.delete('pi_name')      
      hash['enrolling'] = hash.delete('enrolling')
      hash['research_type'] = map_research_type 
      hash['source']  = 'Nct'            
      hash
    end

  end
  class ScrippsImedrisTrial < Trial
    @fields = %w(irb_number investigator title research_type summary inclusion_criteria exclusion_criteria additional_info contact_name contact_email contact_phone date_submitted date_approved)
    @fields.each do |i|
      define_method("#{i}") do
         @trial[i]
      end
      define_method("#{i}=") do |value|
         @trial[i] = value         
      end
    end
    def clean
    end
    
    def self.fields
      @fields
    end
    def to_hash
      hash = @trial.dup()
      criteria = []
      criteria <<  ('<h3>Inclusion Criteria</h3>' + hash.delete('inclusion_criteria').to_s ) if hash['inclusion_critieria'] != ""
      criteria <<  ('<h3>Exclusion Criteria</h3>' + hash.delete('exclusion_criteria').to_s ) if hash['exclusion_criteria']  != ""
      criteria <<  ('<h3>Additional Info</h3>'    + hash.delete('additional_info').to_s )    if hash['additional_info']     != ""
      hash['criteria'] = criteria.join("\n")
      hash['source']  = 'Imedris'
      hash['enrolling'] = 'Yes'

      exclusion_criteria additional_info 
     hash
    end
  end
end

