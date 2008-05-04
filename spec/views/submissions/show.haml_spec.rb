require File.dirname(__FILE__) + '/../../spec_helper'

describe "/submissions/show.haml" do
  include SubmissionsHelper

  before do
    @submission = mock_model(Submission)
    @submission.stub!(:submitter_name).and_return("MyString")
    @submission.stub!(:submitter_url).and_return("MyString")
    @submission.stub!(:business_item_name).and_return("MyString")
    @submission.stub!(:committee_id).and_return("1")
    @submission.stub!(:date).and_return(Date.today)
    @submission.stub!(:evidence_url).and_return("MyString")
    @submission.stub!(:business_item_type).and_return("MyString")
    @submission.stub!(:business_item_id).and_return("1")
    @submission.stub!(:is_from_organisation).and_return(false)
    @submission.stub!(:submitter_type).and_return("MyString")
    @submission.stub!(:submitter_id).and_return("1")

    assigns[:submission] = @submission
  end

  it "should render attributes in <p>" do
    render "/submissions/show.haml"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/als/)
    response.should have_text(/MyString/)
  end
end

