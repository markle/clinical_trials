module ClinicalTrials

  #takes a list of objects as an argument
  #calls to_hash on each of them, if they are not already hashes
  #and then returns a hash of a combination of all their values
  #the arguments should be provided in precedence order
  # so Assembler.new( 
  #        {"1" => "a1", "2" => "a2", "3" => "a3"},
  #        {"2" => "b2", "3" => "b3", "4" => "b4"}
  #        )
  #
  #will produce {"1"=>"a1", "2"=>"a2", "3"=>"a3", "4"=>"b4"}
  #
  # and Assembler.new( 
  #        {"2" => "b2", "3" => "b3", "4" => "b4"},
  #        {"1" => "a1", "2" => "a2", "3" => "a3"}
  #        )
  #
  #will produce {"1"=>"a1", "2"=>"b2", "3"=>"b3", "4"=>"b4"}
  #

 class Merger
   attr_accessor :attributes
   def initialize(list = []) 
      @attributes = {}
      list.compact!
      list.each {|member| 
        hash = member.to_hash
        underwrite(hash)
       }
  end
  
  def to_hash
    @attributes.to_hash
  end  

  def overwrite(update)
     @attributes.update(update) {|key, v1, v2| 
          v2 || v1
       }
   end
   def underwrite(update)
     @attributes.update(update) {|key, v1, v2| 
          v1 || v2
       }
   end
  end
end
