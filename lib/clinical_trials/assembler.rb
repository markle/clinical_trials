module ClinicalTrials

  #there are two lists, the nct list and the imdedris list
  #they need to be merged, so any overlap can be accounted for
  # they will be merged on their irb_number, which both of them have
  class Assembler

    attr_accessor :nct_list, :imedris_list, :assembled

    def initialize(nct_list, imedris_list)
      @nct_list = nct_list
      @imedris_list = imedris_list
      @assembled = []
      assemble
      self #for some reason i need to return self?
    end

    # assemble acts to combine the two lists into an itermediary form
    # called 'an assemblage'
    def assemble
      @assembled = create_assemblages
    end

    ## what this does is combine two lists based on shared properites
    ## 
    ## this may _algorythimicly_ have a better way
    ## who knows maybe there is some version of map that does this
    ## until I learn better, this code is tested, and it works. 
    def merge_lists
      nct_list = @nct_list.dup()
      imedris_list = @imedris_list.dup()
      to_assemble = []
      while (nct_list + imedris_list).length > 0 do
        nct_trial     = nil
        imedris_trial = nil
        if nct_list.length > 0
          nct_trial = nct_list.shift
          imedris_match_index = imedris_list.select { |match| match.irb_number == nct_trial.irb_number }.first
          imedris_trial = imedris_list.delete_at(imedris_list.index(imedris_match_index)) if imedris_match_index
        else
          imedris_trial = imedris_list.shift
        end
        to_assemble << {:imedris => imedris_trial, :nct => nct_trial}
      end
      return to_assemble
    end

    def create_assemblages
      assembled = []
      merged = merge_lists
      merged.each { |pair| assembled << Assemblage.new(pair[:nct], pair[:imedris]) } if merged
      assembled
    end

    ## this is where fetching from clinicaltrials.gov is initiated
    def self.fetch_all_from_web(list)
      # puts 'fetching all from web'
      list.each do |assemblage|      
        assemblage.clinical_trials_dot_gov
      end
      
    end

    def self.from_lists(nct_list, imedris_list)
      list = self.new(nct_list, imedris_list)
      return list.assembled
    end
    
  end
end