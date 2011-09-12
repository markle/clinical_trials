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
  let(:update) {ClinicalTrials::Update.new()}
  subject {update}
  
  
  describe 'when run is called' do
    before do
      ClinicalTrials.configure do |config|
       config.imedris_file = '../spec/examples/imedris_clinical_trials.txt'
       config.nct_file     = 'http://some_nct_file.txt'
      end    
    end

    it 'grabs the latest from nct' do
      ClinicalTrials::Lists::NctList.should_receive(:get_trials)
      update.stub(:imedris_lists).and_return []
      update.stub("update_from_dot_gov!").and_return []
      update.stub("assemble").and_return []
      update.run
    end
    it 'grabs the latest from imedris' do
      ClinicalTrials::Lists::ImedrisList.should_receive(:get_trials)
      update.stub(:nct_lists).and_return []
      update.stub("update_from_dot_gov!").and_return []
      update.stub("assemble").and_return []

      update.run
   end

  end              

   describe 'configuration' do
     it { should respond_to(:config) }

     it 'configures' do
       ClinicalTrials.configure do |config|
        config.imedris_file = 'http://some_imedris_file.txt'
        config.nct_file     = 'http://some_nct_file.txt'
       end
       ClinicalTrials.configuration.imedris_file.should ==  'http://some_imedris_file.txt'
     end

     it 'gets the url of the nct file' do
       update.config.nct_file.should == 'http://some_nct_file.txt'
     end

     it 'gets the url of the imedris file' do
       update.config.imedris_file.should == 'http://some_imedris_file.txt'
     end
  end

end

# i kept this here for the integration that will follow from updat_flow being rewritten.
# describe 'comparing the list of trials to the sparkle list' do
#   before(:all) do
#     Item = Struct.new(:irb_number, :merged_fields)
# 
# 
#     @old = Item.new(1)
#     @same1 = Item.new(2)
#     @same2 = Item.new(2)        
#     @new = Item.new(3)
# 
#     @list_a = [@old, @same1]
#     @list_b = [@same2, @new]
# 
#  end
#   before(:each) do
#     update.stub(:sparkle_lists) {@list_a}
#     update.stub(:assembled) {@list_b}
#  
#   end
#   it 'converts lists to an interchange format' do
#     update.list_to_irb(@list_a).should == [1, 2]
#   end
# 
#   it 'compare lists' do
#    update.to_add.length.should == 1
#    update.to_add.first.irb_number.should == 3
# 
#    update.to_expire.length.should == 1
#    update.to_expire.first.irb_number.should == 1
# 
#   end
#   it 'expires anything old' do 
#    ClinicalTrials::Update::Sparkle.should_receive(:expire).with @old
#     update.expire_old
#   end
#   it 'adds anything new' do
#     ClinicalTrials::Update::Sparkle.should_receive(:add).with @new
#     update.add_new 
#   end
#   it 'updates everything else' do
#     ClinicalTrials::Update::Sparkle.should_receive(:update).with @same1, @same2
#     update.update_same
#   end
# end
