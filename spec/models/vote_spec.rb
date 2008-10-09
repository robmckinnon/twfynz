require File.dirname(__FILE__) + '/../spec_helper'

describe Vote do

  describe 'when asked for bill' do
    it 'should look ask contribution for bill' do
      bill = mock('bill')
      contribution = mock('contribution', :bill => bill)
      vote = Vote.new
      vote.stub!(:contribution).and_return contribution
      vote.bill.should == bill
    end
  end

  describe 'on creation' do
    it 'should default tally of ayes to zero' do
      vote = Vote.new :noes_tally => 1, :abstentions_tally => 1
      vote.valid?
      vote.ayes_tally.should == 0
      vote.noes_tally.should == 1
      vote.abstentions_tally.should == 1
    end

    it 'should default tally of noes to zero' do
      vote = Vote.new :ayes_tally => 1, :abstentions_tally => 1
      vote.valid?
      vote.ayes_tally.should == 1
      vote.noes_tally.should == 0
      vote.abstentions_tally.should == 1
    end

    it 'should default tally of abstentions to zero' do
      vote = Vote.new :ayes_tally => 1, :noes_tally => 1
      vote.valid?
      vote.ayes_tally.should == 1
      vote.noes_tally.should == 1
      vote.abstentions_tally.should == 0
    end
  end

end
