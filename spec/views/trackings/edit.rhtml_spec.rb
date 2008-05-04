require File.dirname(__FILE__) + '/../../spec_helper'

describe "/trackings/edit.rhtml" do
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

  it "should render edit form" do
    render "/trackings/edit.rhtml"

    response.should have_tag("form[action=#{tracking_path(@tracking)}][method=post]") do
      with_tag('input#tracking_item_type[name=?]', "tracking[item_type]")
      with_tag('input#tracking_email_alert[name=?]', "tracking[email_alert]")
      with_tag('input#tracking_include_in_feed[name=?]', "tracking[include_in_feed]")
    end
  end
end


