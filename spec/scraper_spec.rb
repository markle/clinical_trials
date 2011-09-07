#encoding: UTF-8

require './lib/clinical_trials.rb'

describe ClinicalTrials::Scraper do

 let(:nct) { "NCT0000"}
 let(:scraper) { ClinicalTrials::Scraper.new(nct)}
 subject {scraper}

 it {should respond_to :nct}
 describe "Class Methods: fetch_by_nct" do
   it 'should fech_by_nct' do
     itself = double('self')
     ClinicalTrials::Scraper.should_receive(:new).with('filename').and_return itself
     itself.should_receive(:fetch)
     ClinicalTrials::Scraper.fetch_by_nct('filename');
   end
 end
 describe ClinicalTrials::HtmlScraper do
   let(:scraper) { ClinicalTrials::HtmlScraper.new(nct)}
   subject {scraper}

   #it {should respond_to :fetch}
   describe 'creating urls' do
     it 'should have a url from the nct' do
      scraper.nct.should == nct
      scraper.url.should_not == nct
     end
     it 'should be like this  http://clinicaltrials.gov/ct2/show/NCT00495300' do
      scraper.url.should == 'http://clinicaltrials.gov/ct2/show/NCT0000'
     end
   end
   describe 'fetching a trial as html' do
    before do
     @handle = mock();
     @file   = File.open('./spec/examples/NCT00495300');
     scraper.stub(:open) {@handle}
     @handle.stub(:read) {@file}
    end
    it "should read a url" do
       scraper.should_receive(:open)
       @handle.should_receive(:read)
       scraper.fetch
    end
    it "should store the contents of that url as @raw_html" do
      scraper.fetch
      scraper.raw.should_not == nil
    end
  end

 end #html scraper

 describe ClinicalTrials::XmlScraper do
   let(:scraper) { ClinicalTrials::XmlScraper.new(nct)}
   subject {scraper}
   it 'should have a url from the nct' do
      scraper.nct.should == nct
      scraper.url.should_not == nct
   end
   it 'should be like this  http://clinicaltrials.gov/ct2/show/NCT00495300?displayxml=true' do
      scraper.url.should == 'http://clinicaltrials.gov/ct2/show/NCT0000?displayxml=true'
   end

   describe 'fetching a trial as xml' do
    before do
     @handle = mock();
     @file   = File.open('./spec/examples/NCT00495300.xml');
     scraper.stub(:open) {@handle}
     @handle.stub(:read) {@file}
    end
      it "should read a url" do
       scraper.should_receive(:open)
       @handle.should_receive(:read)
       scraper.fetch
    end
    it "should store the contents of that url as @raw" do
      scraper.fetch
      scraper.raw.should_not == nil
    end
   
   end
  end #xml scraper

end #scraper

