#encoding: UTF-8
require './spec/spec_helper.rb'
require './lib/clinical_trials/trial'

describe ClinicalTrials::Trial do
  let(:trial) {ClinicalTrials::Trial.new({})}
  subject {trial}
  before do
    trial.stub(:nct_num) {"NCT0000"}
  end
  it {should respond_to :clean}
  it {should respond_to :dump}
  it 'should return the trials hash with dump' do
    trial.dump.should be_kind_of Hash
  end 
end

describe ClinicalTrials::Trials::NctTrial do
  it 'should return a pile of fields' do
    ClinicalTrials::Trials::NctTrial.fields.length.should > 0
  end
  it {should respond_to :irb_number}
  it {should respond_to :study_title}
  it {should respond_to :pi_name}
  it {should respond_to :research_type}
  it {should respond_to :nct_num}
  describe 'correcting nct nums that are wierd' do
    it "should correct nct nums like NCT#00100101" do
      trial = ClinicalTrials::Trials::NctTrial.new({"nct_num" => "NCT#00100101"})
      trial.nct_num.should == "NCT00100101"
    end
  end
  it {should respond_to :enrolling}
  it "should have getters and setters for fields" do
    #if it has it for irb_number it has it for all of it.
    subject.irb_number = 1
    subject.irb_number.should == 1
  end 
  it "should accept a hash on creation" do
    ClinicalTrials::Trials::NctTrial.new({:key => "value"})
  end
  it "should manifest the properies of that hash" do
    trial = ClinicalTrials::Trials::NctTrial.new({"irb_number" => 1})
    trial.irb_number.should == 1
  end
  
  describe "should check the format of nct strings" do
    it "should like NCT00100101" do
      ClinicalTrials::Trials::NctTrial.check_format("NCT00100101").should == true
    end
    it "should not like NCT#00100101" do
      ClinicalTrials::Trials::NctTrial.check_format("NCT#00100101").should == false

    end
    it "should not like NOT FOUND" do
      ClinicalTrials::Trials::NctTrial.check_format("NOT FOUND").should == false
    end
  end
end

describe ClinicalTrials::Trials::ImedrisTrial do
  it 'should return a pile of fields' do
    ClinicalTrials::Trials::ImedrisTrial.fields.length.should > 0
  end
   it {should respond_to :irb_number}
   it {should respond_to :investigator}
   it {should respond_to :title}
   it {should respond_to :research_type}
   it {should respond_to :summary}
   it {should respond_to :inclusion_criteria}
   it {should respond_to :exclusion_criteria}
   it {should respond_to :additional_info}
   it {should respond_to :contact_name}
   it {should respond_to :contact_email}
   it {should respond_to :contact_phone}
   it {should respond_to :date_submitted}
   it {should respond_to :date_approved}
  it "should have getters and setters for fields" do
    #if it has it for irb_number it has it for all of it.
    subject.irb_number = 1
    subject.irb_number.should == 1
  end 
  it "should accept a hash on creation" do
    ClinicalTrials::Trials::ImedrisTrial.new({:key => "value"})
  end
  it "should manifest the properies of that hash" do
    trial = ClinicalTrials::Trials::ImedrisTrial.new({"irb_number" => 1})
    trial.irb_number.should == 1
  end
end
