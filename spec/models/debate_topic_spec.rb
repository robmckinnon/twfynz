require File.dirname(__FILE__) + '/../spec_helper'

describe DebateTopic do

  describe 'when asked for formerly_part_of_bill' do
    it 'should look ask contribution for bill' do
      former_bill = mock('former_bill')
      bill = mock('bill', :formerly_part_of => former_bill)
      bill.should_receive(:is_a?).with(Bill).and_return true
      debate_topic = DebateTopic.new
      debate_topic.stub!(:topic).and_return bill
      debate_topic.formerly_part_of_bill.should == former_bill
    end
  end
end
