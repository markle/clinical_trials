require "./spec/spec_helper"
require "./lib/clinical_trials/list"
require "./lib/clinical_trials/trial"

describe "Imedris List" do 
  let(:url) {"http://stuff.com"}
  let(:list) {ClinicalTrials::Lists::ImedrisList.new(url)}
  subject { list }
  
  describe 'parsing the list' do
    let(:bad_csv) {
      "pretty much anything without commas\n\n"
    }
    let(:good_csv) {
      <<-DATA.gsub(/^\s*/, '')
       "irb_number","investigator","title","research_type","summary","inclusion_criteria","exclusion_criteria","additional_info","contact_name","contact_email","contact_phone","date_submitted","date_approved"
       "HSC-07-4789","Eric J Topol,  MD","Study of the Genetics of Healthy Aging","Genetics|Genomics|Healthy Donors","This study will work towards identifying the genetic factors responsible for maintaining health. The study is looking at the DNA of individuals who have lived over 80 years and have not experienced a chronic illness or disease. Participantion requires one visit and includes a small blood sample. ","* Be at least 80 years of age","* Have a history of stroke, cancer or other serious condition","","Sarah Topol","topol.sarah@scrippshealth.org","858-554-5747","2009-06-08 00:00:00","2009-06-08 17:36:49.187000000"
       "HSC-07-4789","Eric J Topol,  MD","Study of the Genetics of Healthy Aging","Genetics|Genomics|Healthy Donors","This study will work towards identifying the genetic factors responsible for maintaining health. The study is looking at the DNA of individuals who have lived over 80 years and have not experienced a chronic illness or disease. Participantion requires one visit and includes a small blood sample. ","* Be at least 80 years of age","* Have a history of stroke, cancer or other serious condition","","Sarah Topol","topol.sarah@scrippshealth.org","858-554-5747","2009-06-08 00:00:00","2009-06-08 17:36:49.187000000"
      DATA
    }
    it 'should convert a line of csv to an array' do
      input = '"first","second","third"'
      ClinicalTrials::List.process_csv_row(input).should == ['first', 'second', 'third']
    end
    it 'should create an imedris trial' do
      list.new_trial({:nonsense => "values"}).should be_kind_of ClinicalTrials::Trials::ImedrisTrial
    end
    it 'should parse a good csv' do
      list.stub(:fetch) {good_csv}
      list.parse.should be_kind_of(Array)
    end
    it 'should have 2 trials' do
      list.stub(:fetch) {good_csv}
      list.parse
      list.trials.length.should == 2
    end
    describe 'the first entry of trials' do
      before do 
        list.stub(:fetch) {good_csv}
        list.parse
      end
      subject {list.trials.first}
      it 'should have an instance of Trials::NctTrial as the first entry of trial' do
        subject.should be_kind_of ClinicalTrials::Trials::ImedrisTrial
      end
      it 'should have matching attributes with the csv' do
        subject.irb_number.should == "HSC-07-4789" #in accordance with the csv 
        subject.title.should be_longer_than 20     #seriously long title
      end
    end
    describe 'dealing with realworld data' do
      let(:real_world_csv) { "./spec/examples/imedris_clinical_trials_cleaned.txt" }
       it 'should parse a csv csv' do
        list = ClinicalTrials::Lists::ImedrisList.new(real_world_csv)

        list.parse.should be_kind_of(Array);
      end
    end
  end
  
  
  describe "ClinicalTrials::Lists::ImedrisList" do 
    let(:test_file) {"./spec/examples/imedris_dirty.csv"}
    subject {ClinicalTrials::Lists::ImedrisList.new(test_file)}
      before do
          @trials = ClinicalTrials::Lists::ImedrisList.new(test_file)
          @trials.parse
      end
      it "should return 21 of them" do
          @trials.trials.length.should == 21
      end
      describe 'the first returned trial' do
        subject {@trials.trials.first}
        it {should be_kind_of ClinicalTrials::Trials::ImedrisTrial}
        its(:irb_number) {should == 'HSC-04-2524'}
  
     end    
  end
end

