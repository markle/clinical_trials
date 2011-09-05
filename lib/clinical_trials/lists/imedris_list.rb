module ClinicalTrials
  module Lists
    class ImedrisList < List
      
      def new_trial(trial)
        ClinicalTrials::Trials::ImedrisTrial.new(trial)
      end
      
      def expect
        ClinicalTrials::Trials::ImedrisTrial.fields  
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
          @expected_rows.length.times do |i|
            trial[@expected_rows[i]] = row[i]  
          end
          @trials << new_trial(trial)
        end
      end
      
    end
  end
end
