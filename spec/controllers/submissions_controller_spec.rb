require File.dirname(__FILE__) + '/../spec_helper'

describe SubmissionsController, "#route_for" do

  it "should map { :controller => 'submissions', :action => 'index' } to /submissions" do
    route_for(:controller => "submissions", :action => "index").should == "/submissions"
  end

  it "should map { :controller => 'submissions', :action => 'new' } to /submissions/new" do
    route_for(:controller => "submissions", :action => "new").should == "/submissions/new"
  end

  it "should map { :controller => 'submissions', :action => 'show', :id => 1 } to /submissions/1" do
    route_for(:controller => "submissions", :action => "show", :id => "1").should == "/submissions/1"
  end

  it "should map { :controller => 'submissions', :action => 'edit', :id => 1 } to /submissions/1/edit" do
    route_for(:controller => "submissions", :action => "edit", :id => "1").should == "/submissions/1/edit"
  end

  it "should map { :controller => 'submissions', :action => 'update', :id => 1} to /submissions/1" do
    assert_generates("/submissions/1", :controller => "submissions", :action => "update", :id => "1")
  end

end

describe SubmissionsController, "handling GET /submissions" do

  before do
    @submission = mock_model(Submission)
    @submission.stub!(:populate_submitter_id)
    Submission.stub!(:find_by_sql).and_return([@submission])
    @controller.stub!(:admin?).and_return(true)
  end

  def do_get
    get :index
  end

  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render index template" do
    do_get
    response.should render_template('index')
  end

  it "should find all submissions" do
    do_get
  end

  it "should assign the found submissions for the view" do
    do_get
    assigns[:submissions].should == [@submission]
  end
end

describe SubmissionsController, "handling GET /submissions/1" do

  before do
    @submission = mock_model(Submission)
    Submission.stub!(:find).and_return(@submission)
    @controller.stub!(:admin?).and_return(true)
  end

  def do_get
    get :show, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render show template" do
    do_get
    response.should render_template('show')
  end

  it "should find the submission requested" do
    Submission.should_receive(:find).with("1").and_return(@submission)
    do_get
  end

  it "should assign the found submission for the view" do
    do_get
    assigns[:submission].should equal(@submission)
  end
end

describe SubmissionsController, "handling GET /submissions/1.xml" do

  before do
    @submission = mock_model(Submission, :to_xml => "XML")
    Submission.stub!(:find).and_return(@submission)
    @controller.stub!(:admin?).and_return(true)
  end

  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :show, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should find the submission requested" do
    Submission.should_receive(:find).with("1").and_return(@submission)
    do_get
  end

  it "should render the found submission as xml" do
    @submission.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end
end

describe SubmissionsController, "handling GET /submissions/new" do

  before do
    @submission = mock_model(Submission)
    Submission.stub!(:new).and_return(@submission)
    @controller.stub!(:admin?).and_return(true)
  end

  def do_get
    get :new
  end

  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render new template" do
    do_get
    response.should render_template('new')
  end

  it "should create an new submission" do
    Submission.should_receive(:new).and_return(@submission)
    do_get
  end

  it "should not save the new submission" do
    @submission.should_not_receive(:save)
    do_get
  end

  it "should assign the new submission for the view" do
    do_get
    assigns[:submission].should equal(@submission)
  end
end

describe SubmissionsController, "handling GET /submissions/1/edit" do

  before do
    @submission = mock_model(Submission)
    Submission.stub!(:find).and_return(@submission)
    @controller.stub!(:admin?).and_return(true)
  end

  def do_get
    get :edit, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render edit template" do
    do_get
    response.should render_template('edit')
  end

  it "should find the submission requested" do
    Submission.should_receive(:find).and_return(@submission)
    do_get
  end

  it "should assign the found Submission for the view" do
    do_get
    assigns[:submission].should equal(@submission)
  end
end

describe SubmissionsController, "handling POST /submissions" do

  before do
    @submission = mock_model(Submission, :to_param => "1", :save => true)
    Submission.stub!(:new).and_return(@submission)
    @params = {}
    @controller.stub!(:admin?).and_return(true)
  end

  def do_post
    post :create, :submission => @params
  end

  it "should create a new submission" do
    Submission.should_receive(:new).with(@params).and_return(@submission)
    do_post
  end

  it "should redirect to the new submission" do
    do_post
    response.should redirect_to(submission_url("1"))
  end
end

describe SubmissionsController, "handling PUT /submissions/1" do

  before do
    @submission = mock_model(Submission, :to_param => "1", :update_attributes => true)
    @submission.stub!(:reload)
    @submission.stub!(:business_item_name).and_return ''
    @submission.stub!(:evidence_url).and_return ''
    @submission.stub!(:submitter_url).and_return ''
    @submission.stub!(:submitter_name).and_return ''
    @submission.stub!(:is_from_organisation).and_return(false)
    Submission.stub!(:find).and_return(@submission)
    @controller.stub!(:admin?).and_return(true)
  end

  def do_update
    put :update, :id => "1"
  end

  it "should find the submission requested" do
    Submission.should_receive(:find).with("1").and_return(@submission)
    do_update
  end

  it "should update the found submission" do
    @submission.should_receive(:update_attributes)
    do_update
    assigns(:submission).should equal(@submission)
  end

  it "should assign the found submission for the view" do
    do_update
    assigns(:submission).should equal(@submission)
  end

  it "should redirect to the submission" do
    do_update
    response.should render_template('_submission')
  end
end
