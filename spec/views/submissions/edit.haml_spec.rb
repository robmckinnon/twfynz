require File.dirname(__FILE__) + '/../../spec_helper'

describe "/submissions/edit.haml" do
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

  it "should render edit form" do
    render "/submissions/edit.haml"

    response.should have_tag("form[action=#{submission_path(@submission)}][method=post]") do
      with_tag('input#submission_submitter_name[name=?]', "submission[submitter_name]")
      with_tag('input#submission_submitter_url[name=?]', "submission[submitter_url]")
      with_tag('input#submission_business_item_name[name=?]', "submission[business_item_name]")
      with_tag('input#submission_evidence_url[name=?]', "submission[evidence_url]")
      with_tag('input#submission_business_item_type[name=?]', "submission[business_item_type]")
      with_tag('input#submission_is_from_organisation[name=?]', "submission[is_from_organisation]")
      with_tag('input#submission_submitter_type[name=?]', "submission[submitter_type]")
    end
  end
end


