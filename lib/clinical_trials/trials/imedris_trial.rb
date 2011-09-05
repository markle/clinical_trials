module ClinicalTrials
  module Trials
    class ImedrisTrial < Trial
      
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
        hash
      end

    end
  end
end