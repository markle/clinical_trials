module ClinicalTrials
  # the eligibility part of the xml is one big list
  # it's got it's own syntax but it's a mystery to me
  class EligibilityCleaner

    def initialize(eligibility)
      @input  = eligibility
      @output = @input.dup
    end

    def normalize
      return @output if @normalized
      @output.gsub!(/^\s*([A-Z]{2,})/, '\1')   # unindent capital lines
      @output.gsub!(/\n\s{2,}\b/, " ")         # mush long lines together
      @output.gsub!("-  ", "- ")
      @output.gsub!(/^\b/, "\t")               # indent every line
      @output.gsub!(/^\s*([A-Z]{2,})/, '\1')   # unindent capital lines
      @output.gsub!(/\n\n/, "\n")              # indent every line
      @output
    end

    def clean
      normalize
      @output
    end

    def format
      @input << "\n " # pad the bottom,
      @last_indent ||= 100
      @open_ul ||= []
      @open_li ||= []
      @output = ""
      @input.each_line do |line|
        output = ""
        next if line == "\n"

        printed = false
        printed = true if line == " " #don't print padding
        @last_indent_space = ""
        @last_indent.times { @last_indent_space << " "}
        indent =  line.match(/^([^A-Za-z0-9*]*)/)[0]
        indent_space = indent.gsub(/-/, "")
        dashed =   !!line.match(/^(\s*)-\s*/)
        line_text = line.gsub(/^\s*-\s*/, "")
        coloned =  !!line.match(/:$/)

        numbered = !!line.match(/^(\s*[0-9]*\.\s)/)
        #reset the indent level if it's numbered

        indent =  line.match(/^(\s*[0-9]*\.\s)/)[0] if numbered
        indent =  line.match(/^(\s*)-\s*/)[0] if dashed

        indent_level = indent.length   

        same =     (@last_indent - indent_level) == 0
        deeper =   @last_indent < indent_level
        shallower = @last_indent > indent_level 
        open_li =   @open_li.length > 1 
        open_ul =   @open_ul.length > 1 


        if deeper
          output << "#{indent_space[0..-2]}<ul>\n"
          @open_ul << indent_space[0..-2]
        end

        unless @open_li.empty? && @open_li.empty?

          while (indent_level < (@open_li.last || "").length) || (indent_level < (@open_ul.last || "").length)
            if @open_li.empty? && !@open_ul.empty?
              output << "#{@open_ul.pop}</ul>\n"
              next
            end  
            if @open_ul.empty? && !@open_li.empty?
              output << "#{@open_li.pop}</li>\n"
              next
            end  

            if @open_li.last.length >= @open_ul.last.length 
              output << "#{@open_li.pop}</li>\n"
            else
              output << "#{@open_ul.pop}</ul>\n"
            end
          end
        end  

        if same  &&  (dashed  || numbered )                      
          output << "#{@open_li.pop}</li>\n"
        end     

        if (dashed || numbered)
          output << "#{indent_space}<li>\n"
          @open_li << indent_space      
        end

        # if numbered
        #   output << "#{indent_space}  #{line_text}"  
        # end

        if same  &&  !dashed && !printed && @open_li.length == 0

          output << "<h4>#{line.strip}</h4>\n"
          printed = true        
        end


        if same  &&  !dashed && !printed
          output << " #{line_text}"
          printed = true
        end


        if shallower  &&  coloned && !(dashed || numbered) && !printed    
          output << "<h3>#{line.strip}</h3>\n" 
          printed = true

        end
        if shallower  &&  !coloned && !(dashed || numbered) && !printed
          output << "<h4>#{line.strip}</h4>\n"
          printed = true

        end
        if deeper  &&  !coloned && !(dashed || numbered) && !printed && @open_li.length == 0

          output << "<h4>#{line.strip}</h4>\n"
          printed = true

        end

        if !printed
          output << "#{indent_space}  #{line_text}"  
          printed = true
        end

        @last_indent = indent_level  
        # puts "#{sprintf("%05d", indent_level)} #{output} "
        @output << output
      end 
      @open_li.length.times { @output << "</li>" }                        
      @open_ul.length.times { @output << "</ul>" }   
      @output

    end

    def self.clean(input)
      out = self.new(input)
      out.clean
    end

    def self.format(input)
      out = self.new(input)
      out.format
    end

  end
end
