module ClinicalTrials
  module Lists
    class NctList < List
      
      def expect
        ClinicalTrials::Trials::NctTrial.fields
      end
      
      def new_trial(trial)
        ClinicalTrials::Trials::NctTrial.new(trial)
      end
      
    end
  end
end