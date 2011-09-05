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
        http.start do
          http.request_get(uri.path) do |res|
            contents =  res.body
          end
        end
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
        @expected_rows.length.times do |i|
          trial[@expected_rows[i]] = row[i]  
        end
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