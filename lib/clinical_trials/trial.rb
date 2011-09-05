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
end

