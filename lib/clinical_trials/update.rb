module ClinicalTrials
  # the Update module is the actual heart of what's happening here
  # i heard a great word today 'wheelhouse'
  # this is the wheelhouse
  class Update

    attr_accessor :config

    def self.run
      runner = self.new
      runner.run
    end

    def initialize(config_file = "./config/clinical_trials_config.yml")
      @config_file = config_file
      configure
    end

    def run
      #begin 
        get_lists        
        assemble
        webfetch
        expire_old        
        update_same
        add_new
      #rescue => e
      #  Airbrake.notify(e)
      #end  
    end

    def nct_lists
      @nct_list ||= ClinicalTrials::Lists::NctList.get_trials(@config['nct_file'])
    end

    def imedris_lists
      @imedris_list ||= ClinicalTrials::Lists::ImedrisList.get_trials(@config['imedris_file'])
    end

    def assembled
      @assembled ||= ClinicalTrials::Assembler.from_lists(nct_lists, imedris_lists)    
    end

    def webfetch
      ClinicalTrials::Assembler.fetch_all_from_web(@assembled)
    end

    alias assemble assembled

    def sparkle_lists
      @sparkle_list ||= Update::Sparkle.list
    end

    def list_to_irb(list)
      return [] unless list
      list.collect{|item| item.irb_number}
    end

    def to_add
      research = list_to_irb(assembled)
      sparkle =  list_to_irb(sparkle_lists)
      add = research - sparkle
      return [] unless assembled
      assembled.collect {|trial| trial if add.include?(trial.irb_number)}.compact
    end

    def to_expire
      research = list_to_irb(assembled)
      sparkle =  list_to_irb(sparkle_lists)
      expire = sparkle - research
      return [] unless sparkle_lists
      sparkle_lists.collect {|trial| trial if expire.include?(trial.irb_number)}.compact
    end

    def to_update
      research = list_to_irb(assembled)
      sparkle =  list_to_irb(sparkle_lists)
      keep = (sparkle & research) # & is the itersection operator!
      return [] unless keep
      keepers = keep.collect do |irb_number|
        assemblage = assembled.detect { |i| i.irb_number == irb_number}
        sparkle_trial = sparkle_lists.detect {|i| i.irb_number == irb_number}
        [sparkle_trial, assemblage]
      end
      keepers.compact
    end

    def add_new
      puts "#{to_add.length} to add "
      to_add.each do |assemblage|
        Update::Sparkle.add(assemblage)
      end
    end

    def expire_old
      puts "#{to_expire.length} to expire "

      to_expire.each do |sparkle_trial|
        Update::Sparkle.expire(sparkle_trial)
      end

    end

    def update_same
      puts "#{to_update.length} to update"

      to_update.each do |update|
        sparkle_trial = update[0]
        assemblage    = update[1]
        Update::Sparkle.update(sparkle_trial, assemblage)
      end
    end

    def get_lists
      nct_lists
      imedris_lists
      sparkle_lists
    end

    private

    def configure
      config_file = @config_file
      unless File.exists?(config_file)
        nice_error = <<-NICE_ERROR
        ClinicalTrials::Update requires a config file.
        we looked for one at #{config_file}, but didn't find one.
        NICE_ERROR
        raise ArgumentError, nice_error, caller
      end
      @config = YAML.load(File.read(config_file))
      check_config
    end

    def check_config
      config_file = @config_file
      if not @config['nct_file']
        nice_error = <<-NICE_ERROR
        the configuration file #{config_file} contains errors:
        it needs to contain an url for a nct_file
        NICE_ERROR
        raise SyntaxError, nice_error, caller 
      end

      if not @config['imedris_file']
        nice_error = <<-NICE_ERROR
        the configuration file #{config_file} contains errors:
        it needs to contain an url for a nct_file
        NICE_ERROR
        raise SyntaxError, nice_error, caller 
      end

    end
  end
end

module ClinicalTrials
  class Update::Sparkle

    def self.list
      ClinicalTrial.find_all_active
    end

    def self.expire(sparkle_trial)
      #sparkle_trial.archive
      sparkle_trial.reload
      sparkle_trial.publishing_status = 'archived'
      sparkle_trial.save!
    end

    def self.add(assemblage)
      interchange = assemblage.merged_fields
      ClinicalTrial.update_or_create_trial_from_import(interchange)
    end

    def self.update(sparkle_trial, assemblage)
      interchange = assemblage.merged_fields
      ClinicalTrial.update_or_create_trial_from_import(interchange)
    end

  end
end
