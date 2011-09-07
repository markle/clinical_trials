require './spec/spec_helper'
require './lib/clinical_trials/assembler.rb'
require './lib/clinical_trials'

describe ClinicalTrials::Assembler do
  let(:nct_example) {'./spec/examples/example_nct.txt'}
  let(:imedris_example) {'./spec/examples/imedris_clinical_trials.txt'}
  before(:all) do
    @nct_list = ClinicalTrials::Lists::NctList.get_trials(nct_example)
    @imedris_list = ClinicalTrials::Lists::ImedrisList.get_trials(imedris_example)
    @assembler = ClinicalTrials::Assembler.new(@nct_list, @imedris_list)
 
  end
  it 'takes an nct_list and an imedris list as arguments' do
    @assembler.should be
  end
  # it 'should raise an error if either of those are bad lists' do
  #   @nct_list = ClinicalTrials::Lists::NctList.get_trials(nct_example)
  #   @bad_imedris_list = nil
  #   expect {ClinicalTrials::Assembler.new(@nct_list, @imedris_list)} to_raise


     
  # end
  it 'should have called assemble on creation' do
    @assembler.assembled.should_not == []
  end

  describe 'assembling' do
    let(:imedris_list)  {
      [
        ClinicalTrials::Trials::ImedrisTrial.new({'irb_number' => 2}),
        ClinicalTrials::Trials::ImedrisTrial.new({'irb_number' => 3})
      ]
    }
    let(:nct_list) {
      [
        ClinicalTrials::Trials::NctTrial.new({'irb_number' => 1}),
        ClinicalTrials::Trials::NctTrial.new({'irb_number' => 2})
      ]
    }
    let(:assembler) {ClinicalTrials::Assembler.new(nct_list, imedris_list)}
    it 'should respond to assemble' do
      @assembler.should respond_to :assemble
    end
    it 'should call merge list from within assemble' do
      @assembler.should_receive(:merge_lists)
      @assembler.assemble
    end

    describe 'merge lists' do
      let(:merged_lists) {assembler.merge_lists}
        #the ideal circumstance here is that 
        # 0 = imedris, nil
        # 1 = imedris, nct
        # 2 = nil, nct
        it 'should return an array from merge_lists' do
          merged_lists.should be_kind_of Array
        end
        it 'should not empty out the supplied lists' do
          assembler.nct_list.should_not == []
        end
        it 'should merge two lists together based on their irb_numbers' do
          assembler.merge_lists.should_not == []
        end
        it 'should combine nct trials and imedris trials with the same irb_number' do
         a = merged_lists[1][:nct].irb_number
         b = merged_lists[1][:imedris].irb_number
         a.should == b
        end
        it 'should leave null pairs of studies with no matching irb numbers' do
          merged_lists[0][:imedris].should == nil
          merged_lists[2][:nct].should == nil
        end
    end
    describe 'for each member of the combined list' do
      it 'should call create_assemblage' do
        assembler.should_receive(:create_assemblages)
        assembler.assemble
      end
    end
    it 'should populate @assembled with Assemblages' do
      assembler.assemble
      assembler.assembled.first.should be_kind_of ClinicalTrials::Assemblage
    end
  end
  
  it 'should fetch the clinical_trials, upon request' do
    ClinicalTrials::Assembler.should respond_to(:fetch_all_from_web)

  end
  
  describe 'class methods' do
    it 'should return a list of assemblages as self.from_list' do
     #ClinicalTrials::Assembler.should_receive(:new)
     outlist = ClinicalTrials::Assembler.from_lists(@nct_list, @imedris_list)
     outlist.should be_kind_of Array
     outlist.first.should be_kind_of ClinicalTrials::Assemblage
    end
  end

end


describe ClinicalTrials::Assemblage do
  let(:xml_contents) { File.read('./spec/examples/NCT00495300.xml')}
  
  let(:assemblage){ 
    ClinicalTrials::Assemblage.new(
      ClinicalTrials::Trials::NctTrial.new({'irb_number' => "NCT001", 'nct_num' => "NCT001"}), 
      nil
    )
  }
  let(:imedris_assemblage){ 
    ClinicalTrials::Assemblage.new(      
      nil,
      ClinicalTrials::Trials::ImedrisTrial.new({'irb_number' => "HSC-04-2524"})
    )
  }

  
  it {should respond_to :nct_trial}
  
  it {should respond_to :imedris_trial}
  
  it {should respond_to :clinical_trials_dot_gov}
  
  it 'should take two arguments' do
    ClinicalTrials::Assemblage.new('a', 'b')
  end

  it 'should check the nct_number and nil if it doesnt match' do
    assemblage.nct_trial.nct_num = "1"
    assemblage.trial_number.should == nil
  end
  
  it 'should pass the nct_number if its good' do
    assemblage.nct_trial.nct_num = "NCT001"
    assemblage.trial_number.should == "NCT001"
  end

  it 'should have an irb_number from imedris' do
    
    imedris_assemblage.irb_number.should == "HSC-04-2524"
  end


  it 'should make a long distance fetch when clinical_trials_dot_gov_xml is called' do
    ClinicalTrials::XmlScraper.should_receive(:fetch_by_nct) {xml_contents}
    assemblage.clinical_trials_dot_gov_xml
  end

  it 'should return a parser' do
    ClinicalTrials::XmlScraper.should_receive(:fetch_by_nct) {xml_contents}
    assemblage.clinical_trials_dot_gov.should be_kind_of ClinicalTrials::Parser
  end

  describe "Merging" do
    it 'should invoke the Merger class from merged_fields' do
      merge_mock = double(ClinicalTrials::Merger).as_null_object
      ClinicalTrials::Merger.should_receive(:new) { merge_mock }
      assemblage.merged_fields
    end
    it 'should return a hash' do
       assemblage.merged_fields.should be_kind_of Hash
    end
    describe 'an set of examples' do
      before do
        @imedris = ClinicalTrials::Trials::ImedrisTrial.new()  
        @imedris.irb_number  = "NCT001"

        @imedris.investigator        = "imedris investigator"
        @imedris.title               = "imedris title"
        @imedris.research_type       = "imedris research_type"
        @imedris.summary             = "imedris summary"
        @imedris.inclusion_criteria  = "imedris inclusion_criteria"
        @imedris.exclusion_criteria  = "imedris exclusion_criteria"
        @imedris.additional_info     = "imedris additional_info"
        @imedris.contact_name        = "imedris contact_name"
        @imedris.contact_email       = "imedris contact_email"
        @imedris.contact_phone       = "imedris contact_phone"

        @nct =     ClinicalTrials::Trials::NctTrial.new()
        @nct.irb_number              = "NCT001"
        @nct.study_title             = "nct study_title"
        @nct.pi_name                 = "nct pi_name"
        @nct.research_type           = "nct research_type"
        @nct.nct_num                 = "nct nct_num"
        @nct.enrolling               = "nct enrolling"

        @parser =  nil 
        @parser_xml = <<-XML
				<clinical_study>
				  <id_info>
				    <nct_id>NCT0001</nct_id>
				  </id_info>
				  <brief_title>xml title</brief_title>
				  <official_title>long xml title</official_title>
				  <brief_summary>
				    <textblock>xml summary</textblock>
				  </brief_summary>
				  <detailed_description>
				    <textblock>xml detailed description</textblock>
				  </detailed_description>
				  <overall_status>xml enrolling</overall_status>
				  <eligibility><criteria><textblock>xml criteria</textblock></criteria>
				  </eligibility>
				  <overall_contact>
				    <last_name>xml contact_name</last_name>
				    <phone>xml contact_phone</phone>
				    <email>xml contact_email</email>
				  </overall_contact>
				</clinical_study>
				XML

      end
     it 'should merge nct and imedris, leaning heavily on imedris' do
        @goal = {}
        @goal['irb_number']          = "NCT001"
        @goal['investigator']        = "imedris investigator"
        @goal['title']               = "imedris title"
        @goal['research_type']       = "imedris research_type"
        @goal['summary']             = "imedris summary"
        @goal['criteria']            = [
          ("<h3>Inclusion Criteria</h3>" + ('imedris inclusion_criteria') ),
          ("<h3>Exclusion Criteria</h3>" + ('imedris exclusion_criteria') ),
          ("<h3>Additional Info</h3>"    + ('imedris additional_info') )
        ].join("\n")
        @goal['contact_name']        = "imedris contact_name"
        @goal['contact_email']       = "imedris contact_email"
        @goal['contact_phone']       = "imedris contact_phone"

        @goal['enrolling']              = "Yes" # by definition imedris is enrolling
        @goal['nct_num']             = "nct nct_num"
        @goal['source']              = "Imedris"

        @assemblage = ClinicalTrials::Assemblage.new(@nct, @imedris)

        @assemblage.merged_fields.should == @goal
      end
     
    it 'should merge nct and clinicaltrials.gov leaning heavily on nct' do


        @goal = {}
        @goal['irb_number']          = "NCT001"
        @goal['investigator']        = "nct pi_name"
        @goal['title']               = "nct study_title"
        @goal['summary']             = "xml summary"
        @goal['criteria']            = "<h4>xml criteria</h4>\n<ul>\n</ul>"
        @goal['contact_name']        = "xml contact_name"
        @goal['contact_email']       = "xml contact_email"
        @goal['contact_phone']       = "xml contact_phone"
        @goal['status']              = "xml enrolling"
        @goal['research_type']       = "nct research_type"
        @goal['nct_num']             = "nct nct_num"
        @goal['source']              = "Nct"
        @goal['enrolling']           = "nct enrolling"




        @parser =  ClinicalTrials::Parser.new(@parser_xml)
        @assemblage = ClinicalTrials::Assemblage.new(@nct, nil)
        @assemblage.clinical_trial = @parser
        @assemblage.merged_fields.should == @goal

    end 


   end
     
  end
end
if ENV['WEB_ENABLED']
  describe 'Assembler Integration -- Live Web' do
    require 'yaml'
    # assume there is a config file
    # this is an integration test afterall
    it 'should work' do
      @config = ClinicalTrials::Update.new().config
      @nct_list = ClinicalTrials::Lists::NctList.get_trials(@config['nct_file'])   
      @imedris_list = ClinicalTrials::Lists::ImedrisList.get_trials(@config['imedris_file'])
      @assembler = ClinicalTrials::Assembler.new(@nct_list, @imedris_list)
      @assembler.assembled.length.should > 10
      # y @assembler
    end
  end
end
