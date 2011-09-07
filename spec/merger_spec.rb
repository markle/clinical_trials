require './spec/spec_helper'
require './lib/clinical_trials/merger.rb'

work = <<WORK

WORK


describe 'Merger' do
  let(:merger) {ClinicalTrials::Merger.new}
  it 'should have an merger' do
    ClinicalTrials::Merger.should be
  end
  describe 'precedence functions: ' do
    before do
      merger.attributes = {"1" => "a1", "2" => "a2", "3" => "a3"}
      @update =  {"2" => "b2", "3" => "b3", "4" => "b4"}
    end
    describe 'overwrite' do 
      it 'should overwrite an existing attribute' do
        merger.overwrite(@update)
        merger.attributes['2'].should == 'b2'
      end
      it 'should add a new attribute' do
        merger.overwrite(@update)
        merger.attributes['4'].should == 'b4'
      end
      it 'should leave untouched attributes alone' do
        merger.overwrite(@update)
        merger.attributes['1'].should == 'a1'
      end
    end
    describe 'underwrite' do
      it 'should not overwrite an existing attribute' do
        merger.underwrite(@update)
        merger.attributes['2'].should == 'a2'
      end
      it 'should add a new attribute' do
        merger.underwrite(@update)
        merger.attributes['4'].should == 'b4'
      end
      it 'should leave untouched attributes alone' do
        merger.underwrite(@update)
        merger.attributes['1'].should == 'a1'
      end
    end
  end
  describe 'initialization' do
     it 'should take an array of hashes' do
     merger = ClinicalTrials::Merger.new( 
         [{"1" => "a1", "2" => "a2", "3" => "a3"},
         {"2" => "b2", "3" => "b3", "4" => "b4"}]
          )
     merger.to_hash.should == {"1"=>"a1", "2"=>"a2", "3"=>"a3", "4"=>"b4"}
    end
    it 'should call to_hash on all objects in that list' do
      details = {'cat' => 'paws'}

      dupe = double()
      dupe.stub(:to_hash) {details}
      merger = ClinicalTrials::Merger.new(
        [{}, dupe]
      )
      merger.to_hash.should == details

    end

  end
end
