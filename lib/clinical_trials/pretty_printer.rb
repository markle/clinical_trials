module ClinicalTrials
  class PrettyPrinter

    def initialize(path)
      @path = path
      self.class.create_path(@path)
    end

    def out
    end

    def path
      @path
    end

    def nct(file = nil)
      list = Lists::Nct.new(path, file)
      list.trials # a nice return value
    end

    def imedris(file = nil)
      Lists::Imedris.new(path, file)
    end

    def parser(file = nil, name = nil)
      Parser.new(path, file, name)
    end

    def dump_xml_from_nct(nct_file = nil)
      trials = nct(nct_file)
      trials.each do |trial|
        nct_num = trial.nct_num
        next unless ClinicalTrials::Trials::NctTrial.check_format(nct_num)
        file = ClinicalTrials::XmlScraper.fetch_by_nct(nct_num)
        parser(file, nct_num)
      end
    end

    def self.create_path(path_to_create)
      unless File.exists?(path_to_create)
        Dir.mkdir(path_to_create)
      end
      path_to_create
    end

  end
end


module ClinicalTrials  
  #prettyprinter is a method for dumping things to disk
  class PrettyPrinter 

    #base class, basically sets up the path
    class Base

      def initialize(root_path)
        @root_path = root_path 
        @this_path = basename.downcase
        @path = PrettyPrinter.create_path(path)
      end 

      def path
        File.join(@root_path, @this_path)
      end

      def basename
        self.class.to_s.sub(/^.*::/, '')
      end

    end 

    #the output of the parser is fields, this dumps those, and the input file.
    class Parser < Base

      def initialize(path, file = "", name = nil)
        super(path)

        @parser = ClinicalTrials::Parser.new(file)
        File.open(File.join(@path, "#{name ? name + '_' : ''}xml_raw.xml"), "w") do |f|
          f.puts @parser.raw
        end
        File.open(File.join(@path, "#{name ? name + '_' : ''}xml_processed.html"), "w") do |f|
          f.puts "<h1>#{@parser.nct_id}</h1>"
          f.puts @parser.dump.collect{|k, v| "<b>#{k}</b>: <pre>#{v}</pre>"}
          f.puts "<hr>"
        end
      end

    end

    class Lists
      #dumps the imedris trial data 
      class Imedris < Base

        def initialize(path, file = "")
          super(path)

          File.open(File.join(@path, "imedris_raw.csv"), "w") do |f|
            @nct = ClinicalTrials::Lists::ImedrisList.new(file)
            f.puts @nct.dump
          end

          File.open(File.join(@path, "imedris_processed_trial.txt"), "w") do |f|
            trials = ClinicalTrials::Lists::ImedrisList.get_trials(file)
            trials.each  do |trial|
              f.puts trial.dump.to_yaml
            end
          end
        end

      end

      #dumps the nct trial data
      class Nct < Base

        def initialize(path, file = "")
          super(path)

          File.open(File.join(@path, "nct_raw.csv"), "w") do |f|
            @nct = ClinicalTrials::Lists::NctList.new(file)
            f.puts @nct.dump
          end

          File.open(File.join(@path, "nct_processed_trial.txt"), "w") do |f|
            @trials = ClinicalTrials::Lists::NctList.get_trials(file)
            @trials.each do |trial|
              f.puts trial.dump.to_yaml
            end
          end
        end

        def trials 
          @trials 
        end

      end
    end
  end
end
