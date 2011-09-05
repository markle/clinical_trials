module ClinicalTrials
  module Trials
    class NctTrial < Trial

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
  end
end