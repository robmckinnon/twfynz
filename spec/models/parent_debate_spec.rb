require File.dirname(__FILE__) + '/../spec_helper'

describe ParentDebate, 'when it has a single sub_debate' do
  it 'should identify itself as a parent debate with a single sub_debate' do
    debate = ParentDebate.new
    sub_debate = mock(SubDebate)
    debate.stub!(:sub_debates).and_return [sub_debate]
    debate.is_parent_with_one_sub_debate?.should be_true
  end
end
