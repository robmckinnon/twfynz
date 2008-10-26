require File.dirname(__FILE__) + '/../spec_helper'

describe ParliamentParty do

  assert_model_belongs_to :party
  assert_model_belongs_to :parliament

  before(:each) do
    @parliament_party = ParliamentParty.new
  end

  it "should be valid" do
    @parliament_party.should be_valid
  end
end
