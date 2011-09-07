work = <<WORK
---------------------------------------------
Workflow:
  When 'update' is called, 
    it 'grabs the latest from imedris'
    it 'grabs the list of clinical trials from sparkle'
     - anything on the outs, it expires
     - anything new, it adds
     - anything else, it updates
WORK
require './lib/clinical_trials/update.rb'

describe 'Updating The Clinical Trial Store' do
  let(:example_config_file) { "./spec/examples/clinical_trials_config.yml"}
  let(:test_config_file) { "./spec/examples/clinical_trials_config_test.yml"}
  let(:update) {ClinicalTrials::Update.new(example_config_file)}
  subject {update}
 
  describe 'configuration file' do
   it 'throws an error if the file does not exist' do
         expect { ClinicalTrials::Update.new('./config/nothing_here.txt')}.to raise_error(ArgumentError)
    end
    it {should respond_to(:config)}
    it 'gets the url of the nct file' do
      update = ClinicalTrials::Update.new(example_config_file)
      update.config['nct_file'].should == 'http://some_nct_file.txt'
    end
    it 'gets the url of the imedris file' do
      update = ClinicalTrials::Update.new(example_config_file)
      update.config['imedris_file'].should == 'http://some_imedris_file.txt'
    end
    describe 'bad config file' do
      it 'should raise if the configuration is missing an nct_file' do
        config = {}
        config['imedris_file'] ='http://some_imedris_file.txt'
        File.open(test_config_file, 'w') {|f| f << YAML.dump(config)}
        expect {ClinicalTrials::Update.new(test_config_file) }.to raise_error SyntaxError
      end
      it 'should raise if the configuration is missing an imedris_file' do
        config = {}
        config['nct_file'] ='http://some_nct_file.txt'
        File.open(test_config_file, 'w') {|f| f << YAML.dump(config)}
        expect {ClinicalTrials::Update.new(test_config_file) }.to raise_error SyntaxError
      end
    end
 end
  describe 'when run is called' do
    it 'grabs the latest from nct' do
      ClinicalTrials::Lists::NctList.should_receive(:get_trials).and_return []
      update.stub(:imedris_lists).and_return []
      update.stub(:sparkle_lists).and_return []
      update.run
    end
    it 'grabs the latest from imedris' do
      ClinicalTrials::Lists::ImedrisList.should_receive(:get_trials).and_return []
      update.stub(:nct_lists).and_return []
      update.stub(:sparkle_lists).and_return []
      update.run
   end

    it 'grabs the list from sparkle' do
      update.stub(:nct_lists).and_return []
      update.stub(:imedris_lists).and_return []
      update.stub(:sparkle_lists).and_return []
      update.should_receive(:sparkle_lists) {[]}
      update.run
    end

   it 'grabs the list of clinical trials from sparkle' do
     update.stub(:nct_lists).and_return []
     update.stub(:imedris_lists).and_return []
     ClinicalTrials::Update::Sparkle.should_receive(:list) {[]}
     update.run
   end

    describe 'comparing the list of trials to the sparkle list' do
      before(:all) do
        Item = Struct.new(:irb_number, :merged_fields)


        @old = Item.new(1)
        @same1 = Item.new(2)
        @same2 = Item.new(2)        
        @new = Item.new(3)

        @list_a = [@old, @same1]
        @list_b = [@same2, @new]

     end
      before(:each) do
        update.stub(:sparkle_lists) {@list_a}
        update.stub(:assembled) {@list_b}
 
      end
      it 'converts lists to an interchange format' do
        update.list_to_irb(@list_a).should == [1, 2]
      end

      it 'compare lists' do
       update.to_add.length.should == 1
       update.to_add.first.irb_number.should == 3

       update.to_expire.length.should == 1
       update.to_expire.first.irb_number.should == 1

      end
      it 'expires anything old' do 
       ClinicalTrials::Update::Sparkle.should_receive(:expire).with @old
        update.expire_old
      end
      it 'adds anything new' do
        ClinicalTrials::Update::Sparkle.should_receive(:add).with @new
        update.add_new 
      end
      it 'updates everything else' do
        ClinicalTrials::Update::Sparkle.should_receive(:update).with @same1, @same2
        update.update_same
      end
    end
  end
end

