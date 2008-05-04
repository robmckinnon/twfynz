require File.dirname(__FILE__) + '/../spec_helper'


describe Contribution, 'on validation' do

  it 'should be valid when speaker name is "Hon Member"' do
    contribution = Contribution.new(:speaker=>'Hon Member')
    contribution.should be_valid
  end

end

