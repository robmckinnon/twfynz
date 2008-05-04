require File.dirname(__FILE__) + '/../../spec_helper'

describe "/trackings/show.rhtml" do
  include TrackingsHelper

  before do
    @tracking = mock_model(Tracking)
    @tracking.stub!(:user_id).and_return("1")
    @tracking.stub!(:created_at).and_return(Date.today)
    @tracking.stub!(:item_type).and_return("MyString")
    @tracking.stub!(:item_id).and_return("1")
    @tracking.stub!(:email_alert).and_return(false)
    @tracking.stub!(:include_in_feed).and_return(false)

    assigns[:tracking] = @tracking
  end

  it "should render attributes in <p>" do
    render "/trackings/show.rhtml"
    response.should have_text(/MyString/)
    response.should have_text(/als/)
    response.should have_text(/als/)
  end
end

