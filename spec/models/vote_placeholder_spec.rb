require File.dirname(__FILE__) + '/../spec_helper'

describe VotePlaceholder do

  describe 'when asked for bill' do
    it 'should look ask debate for bill' do
      bill = mock('bill')
      debate = mock('debate', :bill => bill)
      placeholder = VotePlaceholder.new
      placeholder.stub!(:debate).and_return debate
      placeholder.bill.should == bill
    end
  end
end
