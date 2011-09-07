# encoding: UTF-8      
require './spec/spec_helper'
require './lib/clinical_trials/pretty_printer'
describe ClinicalTrials::PrettyPrinter do
  let(:test_path) {"./spec/test-dir"}
  let(:pper) {ClinicalTrials::PrettyPrinter.new(test_path)}
  before(:all) do
   `rm -rdf #{test_path}` #clean up before yourself 

  end
  after(:all) do
   #`rm -rdf #{test_path}` #clean up after yourself
  end

  it 'should create a folder' do
    ClinicalTrials::PrettyPrinter.new(test_path)
    File.exists?(test_path).should == true
  end
  

  describe ClinicalTrials::PrettyPrinter::Lists::Nct do
   let(:nct_file) {"./spec/examples/example_nct.txt"}
   subject {pper.nct(nct_file)}

    it 'should create a folder' do
      pper.nct(nct_file)
      File.exists?(File.join(test_path, "nct")).should == true
    end
    it 'should download the file into that folder' do
       pper.nct(nct_file)
       File.exists?(File.join(test_path, "nct", "nct_raw.csv")).should == true
    end
    it 'should put a single trial as a file' do
       pper.nct(nct_file)
       File.exists?(File.join(test_path, "nct", "nct_processed_trial.txt")).should == true
    end
    it 'shoule be able to dump a pile of xml from a list' do
     ClinicalTrials::XmlScraper.should_receive(:fetch_by_nct).exactly(56).times.and_return("return")
     pper.should_receive(:parser).exactly(56).times
     pper.dump_xml_from_nct(nct_file)
    end

  end

  describe ClinicalTrials::PrettyPrinter::Lists::Imedris do
    let(:test_file) {"./spec/examples/imedris_dirty.csv"}
    it 'should create a folder' do
       pper.imedris(test_file)
       File.exists?(File.join(test_path, "imedris")).should == true
    end
    it 'should download the file into that folder' do
       pper.imedris(test_file)
       File.exists?(File.join(test_path, "imedris", "imedris_raw.csv")).should == true
    end
    it 'should put a single trial as a file' do
       pper.imedris(test_file)
       File.exists?(File.join(test_path, "imedris", "imedris_processed_trial.txt")).should == true
    end

  end


  describe ClinicalTrials::PrettyPrinter::Parser do
    let(:xml_path) {"./spec/examples/NCT00495300.xml"}
    let(:xml_file) {File.read(xml_path)}
    subject {pper.parser(xml_file)}
    it 'should create a folder' do
      pper.parser(xml_file, 'test')
      File.exists?(File.join(test_path, "parser")).should == true
    end
    it 'should download the file into that folder' do
       pper.parser(xml_file, 'test')
       File.exists?(File.join(test_path, "parser", "test_xml_raw.xml")).should == true
    end
    it 'should dump a fields file into that folder' do
       pper.parser(xml_file, 'test')
       File.exists?(File.join(test_path, "parser", "test_xml_processed.html")).should == true
    end
  end
  
  if ENV['WEB_ENABLED']

    describe "Mass Fetching Every Xml File listed in the NCT File" do
     let(:nct_file) {"./spec/examples/example_nct.txt"}

     it 'should fetch the nct file' do 
       ClinicalTrials::Lists::NctList.should_receive(:get_trials).and_return []
       pper.dump_xml_from_nct(nct_file)
     end
   
     it 'should populate the xml dir with the files' do
       pper.dump_xml_from_nct(nct_file)
       Dir.entries(File.join(test_path, "parser")).should be_longer_than 4
     end
    end
  end
end

