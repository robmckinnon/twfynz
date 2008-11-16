require File.dirname(__FILE__) + '/../spec_helper'

describe Parliament do

  assert_model_has_many :members
  assert_model_belongs_to :commission_opening_debate

  before(:each) do
    @parliament = Parliament.new
  end

  it "should be valid" do
    @parliament.should be_valid
  end
end
