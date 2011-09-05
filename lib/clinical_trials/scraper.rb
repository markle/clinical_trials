module ClinicalTrials 
  class Scraper
    
   attr_accessor :nct, :url, :raw  
    # the urls are quite readable actually
    # for example, http://clinicaltrials.gov/ct2/show/NCT00495300
    def initialize(trial_number)
      @nct = trial_number
      @url = nct_to_url
    end

    def nct_to_url
      "http://clinicaltrials.gov/ct2/show/" + @nct.upcase
    end
    
    def self.fetch_by_nct(nct)
      file = self.new(nct)
      file.fetch
    end
    
  end

  class HtmlScraper < Scraper
      
      def fetch
        begin
          @raw = open(@url).read
        rescue
          puts "could not fetch #{@url}"
        end
      end
      
  end

  class XmlScraper < Scraper
    
    def nct_to_url
      "http://clinicaltrials.gov/ct2/show/" + @nct.upcase + "?displayxml=true"
    end

    def fetch
      @raw = open(@url).read
    end
    
  end

end
