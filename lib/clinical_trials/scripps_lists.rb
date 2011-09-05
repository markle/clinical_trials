module ClinicalTrials
  #inheiriting classes MUST implement:
  # expect
  # new_trial
  
  class List
    attr_accessor :url, :trials
    def initialize(url)
      @expected_rows = expect
      @url = url || ""
      @file = nil
      @trials = []
    end
    def read(url)
      #puts url
      begin
        contents = open(url).read
      rescue
        contents = ""
        uri = URI.parse(url || 'https://localhost/')
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == "https"  # enable SSL/TLS
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        http.start {
          http.request_get(uri.path) {|res|
            contents =  res.body
          }
        }      #puts contents
      end
      contents = ensure_utf8(contents)
    end
    def fetch
      @file ||= read(@url)
    end
    def ensure_utf8(ugly_string)
        Iconv::conv("utf-8",'utf-16', ugly_string)
    end
    def parse
      @trials = []
      fetched = fetch
      rows = CSV.parse(fetched)
      raise if rows[0] != @expected_rows
      rows.each do |row|
       next if row == @expected_rows
      trial = {}
      @expected_rows.length.times {|i|
        trial[@expected_rows[i]] = row[i]  
      }
      @trials << new_trial(trial)
     end
    end
    def trials      
      @trials
    end
    def expect
      #please replace this with your expectations
      []
    end
    def dump
      fetch
      @file
    end
    def self.get_trials(url)
      list = self.new(url)
      list.fetch
      list.parse
      list.trials
    end
    def self.process_csv_row(row)
       row.strip!
       row.gsub!(/^"/, "")
       row.gsub!(/"$/, "")
       row = row.split('","')
    end
    
  end
end

module ClinicalTrials
  class ScrippsNctList < List
    def expect
      ScrippsNctTrial.fields
    end
    def new_trial(trial)
      ScrippsNctTrial.new(trial)
    end
  end
end


module ClinicalTrials
  class ScrippsImedrisList < List
    def new_trial(trial)
      ScrippsImedrisTrial.new(trial)
    end
    def expect
      ScrippsImedrisTrial.fields  
    end
    def parse 
      fetched = fetch
     @trials = []
     rows = fetched.split("\n")
      raise if self.class.process_csv_row(rows[0]) != @expected_rows
      rows.each do |row|
        row = self.class.process_csv_row(row)
        next if row == @expected_rows
        trial = {}
        @expected_rows.length.times {|i|
           trial[@expected_rows[i]] = row[i]  
        }
        @trials << new_trial(trial)
     end

    end
  end
end
