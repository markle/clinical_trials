# encoding: UTF-8      
require './spec/spec_helper.rb'
require './lib/clinical_trials/parser.rb'


describe ClinicalTrials::Parser do
  let(:contents) { File.read('./spec/examples/NCT00495300.xml')}
  let(:parser) { ClinicalTrials::Parser.new(contents) }
  subject {parser}
  it 'should have a raw attr' do
    parser.raw.should_not == nil
  end
  it 'should convert raw into doc' do
    parser.doc.should_not == nil
    parser.doc.should be_kind_of Nokogiri::XML::Document
  end
  it 'should consist of a study' do
    parser.study
  end
  describe "Fields from the Example" do
  its(:org_study_id) { should == "070183"}
  its(:secondary_id) { should == "07-I-0183"}
  its(:nct_id)       { should == "NCT00495300"}
  its(:condition)    { should == "Hematopoietic Stem Cell Transplantation"}
  its(:title)  { should == "Collection of Samples and Data for the National Marrow Donor Program Repository"}
  its(:official_title)  { should == "The Collection of Research Samples and/or Data for Repository From Related or Unrelated Hematopoietic Stem Cell Transplantation Recipients for the National Marrow Donor Program(Registered Trademark)"}
  its(:summary) { should be_longer_than 100 }

  its(:contact_name) {should == "Patient Recruitment and Public Liaison Office"}
  its(:contact_email) {should == "prpl@mail.cc.nih.gov"}
  its(:contact_phone) {should == "(800) 411-1222"}
  its(:status) {should == 'Recruiting'}
  its(:summary) {should be_longer_than 100} #alias to :brief_summary

  describe 'parsing criteria' do
   its(:eligibility) {  should be_longer_than 100 }
  end
  describe 'dumping' do
    it 'should return a hash of all fields as a dump' do
      parser.dump.should be_kind_of Hash
    end
  end
end
end


