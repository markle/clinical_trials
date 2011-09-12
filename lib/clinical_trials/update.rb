
# a simple class, but the one that should be called externally.
# ClinicalTrials::Update.run is the outward facing class of this whole noodle.
# It returns a simple array of nicely formatted 'assemblages' which match, at least for now
# the implementation that sparkle as using, in terms of columns and such.

class ClinicalTrials::Update
     attr_accessor :nct_list, :imedris_list, :assembled, :config
     def self.run
        runner = self.new
        runner.run
      end
  
      def initialize()
        @config = configure
      end
  
      def run
          @nct_list           = nct_lists
          @imedris_list       = imedris_lists
          @assembled          = assemble(@nct_list, @imedris_list)
          update_from_dot_gov!(@assembled)
          @assembled
      end

      def get_lists
        @nct_list
      end

      def nct_lists
        ClinicalTrials::Lists::NctList.get_trials(@config.nct_file)
      end
  
      def imedris_lists
        ClinicalTrials::Lists::ImedrisList.get_trials(@config.imedris_file)
      end

      def assemble(nct_list, imedris_list)        
        ClinicalTrials::Assembler.from_lists(nct_lists, imedris_lists)    
      end

      def update_from_dot_gov!(assembled)
        ClinicalTrials::Assembler.fetch_all_from_web(assembled)
      end


      def configure
        ClinicalTrials.configuration ||= ClinicalTrials::Configuration.new
      end
            
end