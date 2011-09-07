# encoding: UTF-8

require './lib/clinical_trials/list'
require './lib/clinical_trials/lists/nct_list'

describe ClinicalTrials::List do
  it 'requires an url to initialize' do
    expect { ClinicalTrials::List.new }.to raise_error
  end
  it 'initializes with an url' do
    list = ClinicalTrials::List.new('http://scripps.org/list.csv')
    list.should be
    list.class.to_s.should == "ClinicalTrials::List"
  end

end  
describe ClinicalTrials::Lists::NctList do


    let(:url) {"http://stuff.com"}
    let(:list) {ClinicalTrials::Lists::NctList.new(url)}
    subject { list }

    it 'initializes with an url' do
      list = ClinicalTrials::Lists::NctList.new('http://scripps.org/list.csv')
      list.should be
      list.class.to_s.should == "ClinicalTrials::Lists::NctList"
    end
    
    
    it 'should have an url' do
      list.url.should == url
    end
    

    it "should have trials which is an array" do 
       subject.trials.should be_kind_of(Array)
    end

    it 'should create an nct trial' do
      list.new_trial({:nonsense => "values"}).should be_kind_of ClinicalTrials::Trials::NctTrial
    end

    describe 'fetching the list' do
      it 'should use open-uri to fetch the url' do
        list.should_receive(:read).with(url)
        list.fetch
      end
      it 'should recieve a csv' do
        list.stub(:read) {:csv_return}
        list.fetch.should ==  :csv_return
      end
    end #fetching the list

    describe 'parsing the list' do
      let(:bad_csv) {
        "pretty much anything without commas\n\n"
      }
      let(:good_csv) {
        <<-DATA.gsub(/^\s*/, '')
         "irb_number","study_title","pi_name","research_type","nct_num","enrolling"
         "HSC 08-5085","A Clinical Evaluation of the Medtronic Endeavor Resolute Zotarolimus-Eluting Coronary Stent System in the Treatment of De Novo Lesions in Native Coronary Arteries with a Reference Vessel Diameter of 2.25 mm to 4.2 mm.","Paul Teirstein","Cardiology and Vascular Diseases","NCT#","Yes"
         "HSC-00-111","(NSABP B-31) A Randomized Trial Comparing the Safety and Efficacy of Adriamycin and Cyclophosphamide Followed by Taxol (AC --> T) to that of Adriamycin and Cyclophosphamide Followed by Taxol Plus Herceptin (AC --> T + H) in Node Positive Breast Cancer Patients who have Tumors that Overexpress HER2","James Mason","Obstetrics and Gynecology","NCT00004067","No"
        DATA
      }
      let(:bad_encoding) {
         Iconv::conv("UTF-16",'UTF-8', good_csv)
      }

      it 'should reject a bad csv' do
        list.stub(:fetch) {bad_csv}
        expect {list.parse }.to raise_error
      end

      it 'should parse a good csv' do
        list.stub(:fetch) {good_csv}
        list.parse.should be_kind_of(Array)
      end

      it 'should run ensure_utf8' do
        list.stub(:open) {  StringIO.new(bad_encoding) }
        list.should_receive(:ensure_utf8).with(bad_encoding)
        list.fetch
      end
      it 'should convert utf 16 to utf 8' do
        #bad_encoding
        #good_csv
         list.ensure_utf8(bad_encoding).should == good_csv;
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
          subject.should be_kind_of ClinicalTrials::Trials::NctTrial
        end
        it 'should have matching attributes with the csv' do
          subject.irb_number.should == "HSC 08-5085" #in accordance with the csv 
          subject.study_title.length.should > 20     #seriously long title
        end
      end
    end   

    describe 'dumping' do
      it 'should ensure that you fetch before dumping' do
        subject.should_receive(:fetch)
        subject.dump
      end
      it 'should return the raw file ' do
        subject.should_receive(:read).and_return 'something'
        subject.dump.should == 'something'
      end
    end
    
    
    describe 'Class Methods' do
      describe 'get_trials' do
        it 'should respond to get_trials(url)' do
         ClinicalTrials::Lists::NctList.should respond_to(:get_trials) 
        end
        it 'should instantiate a new List' do
          null =  double('null object').as_null_object 
          ClinicalTrials::Lists::NctList.should_receive(:new).with('fetch_url').and_return(null)
          ClinicalTrials::Lists::NctList.get_trials('fetch_url')
        end
        it 'should fetch and parse that list' do
          list =  double('list').as_null_object 
          ClinicalTrials::Lists::NctList.should_receive(:new).with('fetch_url').and_return(list)
          list.should_receive(:fetch)
          list.should_receive(:parse)
          list.should_receive(:trials)
          ClinicalTrials::Lists::NctList.get_trials('fetch_url')
        end
        it 'should return trials' do
          test_file = "./spec/examples/example_nct.txt"
          list = ClinicalTrials::Lists::NctList.get_trials(test_file)
          list.should be_kind_of Array
          list.first.should be_kind_of ClinicalTrials::Trials::NctTrial
        end
      end
    end

end

describe "Lists::NctList Integration Test" do
  test_file = "./spec/examples/example_nct.txt"
  before do
      @trials = ClinicalTrials::Lists::NctList.new(test_file)
      @trials.parse
  end
  it "should return 58 of them" do
      @trials.trials.length.should == 58
  end
  describe 'the first returned trial' do
    subject {@trials.trials.first}
    it {should be_kind_of ClinicalTrials::Trials::NctTrial}
    its(:irb_number) {should == 'HSC 08-5085'}

  end
 end


