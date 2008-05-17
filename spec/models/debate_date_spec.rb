require File.dirname(__FILE__) + '/../spec_helper'

describe DebateDate, 'when created with month given as a number' do

  before do
    params = {:year => '2008', :month => '5', :day => '14'}
    @date = DebateDate.new params
  end

  it 'should be invalid' do
    @date.is_valid_date?.should be_false
  end

  it 'should have month as three letter string in hash returned from to_hash' do
    @date.to_hash[:month].should == 'may'
  end
end
