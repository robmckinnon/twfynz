require File.dirname(__FILE__) + '/../spec_helper'

describe PlacesController do

  it "should map { :controller => 'places', :action => 'index' } to /places" do
    route_for(:controller => "places", :action => "index").should == "/places"
  end

  it "should map { :controller => 'places', :action => 'show_place', :name => 'puhoi' } to /places/puhoi" do
    route_for(:controller => "places", :action => "show_place", :name => 'puhoi').should == "/places/puhoi"
  end
end

describe PlacesController, "handling GET /places" do

  before do
    @places = []
    Geoname.stub!(:find).and_return(@places)
  end

  it "should be successful" do
    get :index
    response.should be_success
  end

  it "should assign the found places" do
    get :index
    assigns[:places].should == @places
  end

  it "should render index template" do
    get :index
    response.should render_template('index')
  end

end

describe PlacesController, "handling GET /places/name" do

  before do
    @place = mock(Geoname)
    @place.stub!(:feature_code).and_return 'PPL'
    @place.stub!(:latitude).and_return 55
    @place.stub!(:longitude).and_return 55
    @place.stub!(:find_mentions).and_return []
    Geoname.stub!(:find_by_slug).and_return(@place)
  end

  it "should be successful" do
    get :show_place, :name => 'Wellington'
    response.should be_success
  end

  it "should assign the found place" do
    get :show_place, :name => 'Wellington'
    assigns[:place].should == @place
  end

  it "should render show_place template" do
    get :show_place, :name => 'Wellington'
    response.should render_template('show_place')
  end

end

