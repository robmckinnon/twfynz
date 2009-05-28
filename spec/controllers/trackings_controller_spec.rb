require File.dirname(__FILE__) + '/../spec_helper'

describe TrackingsController, "#route_for" do

  it "should map { :controller => 'trackings', :action => 'new' } to /trackings/new" do
    route_for(:controller => "trackings", :action => "new").should == "/trackings/new"
  end

  it "should map { :controller => 'trackings', :action => 'show', :id => 1 } to /trackings/1" do
    assert_generates("/trackings/1", :controller => "trackings", :action => "show", :id => 1)
  end

  it "should map { :controller => 'trackings', :action => 'edit', :id => 1 } to /trackings/1/edit" do
    assert_generates("/trackings/1/edit", :controller => "trackings", :action => "edit", :id => 1)
  end

  it "should map { :controller => 'trackings', :action => 'update', :id => 1} to /trackings/1" do
    assert_generates("/trackings/1", :controller => "trackings", :action => "update", :id => 1)
  end

  it "should map { :controller => 'trackings', :action => 'destroy', :id => 1} to /trackings/1" do
    assert_generates("/trackings/1", :controller => "trackings", :action => "destroy", :id => 1)
  end

end

describe TrackingsController, "handling GET /trackings/1" do

  before do
    @tracking = mock_model(Tracking)
    Tracking.stub!(:find).and_return(@tracking)
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

  it "should find the tracking requested" do
    Tracking.should_receive(:find).with("1").and_return(@tracking)
    do_get
  end

  it "should assign the found tracking for the view" do
    do_get
    assigns[:tracking].should equal(@tracking)
  end
end

describe TrackingsController, "handling GET /trackings/1.xml" do

  before do
    @tracking = mock_model(Tracking, :to_xml => "XML")
    Tracking.stub!(:find).and_return(@tracking)
  end

  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :show, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should find the tracking requested" do
    Tracking.should_receive(:find).with("1").and_return(@tracking)
    do_get
  end

  it "should render the found tracking as xml" do
    @tracking.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end
end

describe TrackingsController, "handling GET /trackings/new" do

  before do
    @tracking = mock_model(Tracking)
    Tracking.stub!(:new).and_return(@tracking)
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

  it "should create an new tracking" do
    Tracking.should_receive(:new).and_return(@tracking)
    do_get
  end

  it "should not save the new tracking" do
    @tracking.should_not_receive(:save)
    do_get
  end

  it "should assign the new tracking for the view" do
    do_get
    assigns[:tracking].should equal(@tracking)
  end
end

describe TrackingsController, "handling GET /trackings/1/edit" do

  before do
    @tracking = mock_model(Tracking)
    Tracking.stub!(:find).and_return(@tracking)
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

  it "should find the tracking requested" do
    Tracking.should_receive(:find).and_return(@tracking)
    do_get
  end

  it "should assign the found Tracking for the view" do
    do_get
    assigns[:tracking].should equal(@tracking)
  end
end

describe TrackingsController, "handling POST /trackings" do

  fixtures :users
  before do
    @tracking = mock_model(Tracking, :to_param => "1", :save => true, :tracking_on => true)
    @tracking.stub!(:user=)
    @tracking.stub!(:item).and_return(mock_model(Bill))
    Tracking.stub!(:new).and_return(@tracking)
    # user = users(:the_bob)
    controller.stub!(:current_user).and_return(mock(User, :login=>'bob'))
    @params = {}
  end

  def do_post
    post :create, :tracking => @params
  end

  it "should create a new tracking" do
    Tracking.should_receive(:new).with(@params).and_return(@tracking)
    do_post
  end

  it "should redirect to the new tracking" do
    do_post
    response.should be_success
  end
end

describe TrackingsController, "handling PUT /trackings/1" do

  before do
    @tracking = mock_model(Tracking, :to_param => "1", :update_attributes => true)
    Tracking.stub!(:find).and_return(@tracking)
    end

  def do_update
    put :update, :id => "1"
  end

  it "should find the tracking requested" do
    Tracking.should_receive(:find).with("1").and_return(@tracking)
    do_update
  end

  it "should update the found tracking" do
    @tracking.should_receive(:update_attributes)
    do_update
    assigns(:tracking).should equal(@tracking)
  end

  it "should assign the found tracking for the view" do
    do_update
    assigns(:tracking).should equal(@tracking)
  end

  it "should redirect to the tracking" do
    do_update
    response.should redirect_to(tracking_url("1"))
  end
end

describe TrackingsController, "handling DELETE /trackings/1" do

  before do
    @tracking = mock_model(Tracking, :destroy => true)
    Tracking.stub!(:find).and_return(@tracking)
  end

  def do_delete
    delete :destroy, :id => "1"
  end

  it "should find the tracking requested" do
    Tracking.should_receive(:find).with("1").and_return(@tracking)
    do_delete
  end

  it "should call destroy on the found tracking" do
    @tracking.should_receive(:destroy)
    do_delete
  end

  it "should redirect to the trackings list" do
    do_delete
    response.should redirect_to(trackings_url)
  end
end
