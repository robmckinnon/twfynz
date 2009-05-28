require File.dirname(__FILE__) + '/../spec_helper'

describe UserController, 'signup' do

  it "should be accessible via route '/users/signup'" do
    route_for(:controller => "user", :action => "signup").should == "/users/signup"
  end

  it "should show initial signup page on GET request" do
    get :signup
    response.should be_success
    response.should render_template("user/signup")
  end

  it 'should, when user chooses individual, redirect to signup_individual' do
    post :signup, :user_type => 'individual'
    response.should be_redirect
    response.should redirect_to(:action => 'signup_individual')
  end

  it 'should, when user chooses organisation, redirect to signup_organisation' do
    post :signup, :user_type => 'organisation'
    response.should be_redirect
    response.should redirect_to(:action => 'signup_organisation')
  end
end

describe UserController, 'signup organisation' do
  fixtures :users

  it "should be accessible via route '/users/signup/organisation'" do
    route_for(:controller => "user", :action => "signup_organisation").should == "/users/signup/organisation"
  end
end

describe UserController, 'signup individual' do
  fixtures :users

  it "should be accessible via route '/users/signup/individual'" do
    route_for(:controller => "user", :action => "signup_individual").should == "/users/signup/individual"
  end

  it "should create user and redirect to user_home" do
    post :signup_individual, :user => { :login => "newbob", :password => "newpassword", :password_confirmation => "newpassword", :email => "newbob@mcbob.com" }
    session[:user].should_not be_nil
    response.should be_redirect
    response.should redirect_to(:action => 'user_home', :user_name => 'newbob')
  end

  it "should fail if password confirmation doesn't match password" do
    post :signup_individual, :user => { :login => "newbob", :password => "newpassword", :password_confirmation => "wrong", :email => "newbob@mcbob.com"}
    session[:user].should be_nil
    # assert_invalid_column_on_record "user", "password"
    response.should be_success
    response.should render_template("user/signup_individual")
  end

  it "should fail if login too short" do
    post :signup_individual, :user => { :login => "yo", :password => "newpassword", :password_confirmation => "newpassword", :email => "newbob@mcbob.com"}
    session[:user].should be_nil
    # assert_invalid_column_on_record "user", "login"
    response.should be_success
    response.should render_template("user/signup_individual")
  end

  it "should fail if login too short and password confirmation doesn't match password" do
    post :signup_individual, :user => { :login => "yo", :password => "newpassword", :password_confirmation => "wrong", :email => "newbob@mcbob.com"}
    session[:user].should be_nil
    # assert_invalid_column_on_record "user", "login"
    response.should be_success
    response.should render_template("user/signup_individual")
  end

  it 'should redirect to user_home page if user logged in' do
    user = mock(User, :login=>'bob')
    User.should_receive(:authenticate).with(user.login,"test").and_return user
    post :login, :user=>{ :login => user.login, :password => "test"}
    response.should be_redirect
    session[:user].should_not be_nil

    get :signup_individual
    response.should be_redirect
    response.should redirect_to(:action => 'user_home', :user_name => 'bob')
  end
end

describe UserController, 'login' do

  fixtures :users

  it "should authenicate user and redirect to user_home" do
    user = mock(User, :login=>'bob')
    User.should_receive(:authenticate).with(user.login,"test").and_return user
    post :login, :user=> { :login => user.login, :password => "test" }
    session[:user].should_not be_nil
    session[:user].should == user
    response.should be_redirect
    response.should redirect_to(:action => 'user_home', :user_name => user.login)
  end

  it "should fail with incorrect password" do
    post :login, :user=> { :login => "bob", :password => "not_correct" }
    session[:user].should be_nil
    # flash[:warning].should == 'Login unsuccessful'
    response.should be_success
    response.should render_template("user/login")
  end

  # it 'should redirect to user_home page if user logged in' do
    # post :login, :user => { :login => "bob", :password => "test" }
    # response.should be_redirect
    # session[:user].should_not be_nil
#
    # get :login
    # response.should be_redirect
    # response.should redirect_to(:action => 'user_home', :user_name => 'bob')
  # end

end

describe UserController, 'logoff' do

  fixtures :users

  # it 'should clear user and redirect to login view' do
    # post :login, :user=>{ :login => "bob", :password => "test"}
    # response.should be_redirect
    # session[:user].should_not be_nil
#
    # get :logout
    # response.should be_redirect
    # session[:user].should be_nil
    # response.should redirect_to(:controller => 'application', :action => 'home')
  # end

end

describe UserController, 'forgot_password' do

  fixtures :users

  it "GET 'forgot_password' should be successful" do
    user = mock(User, :login=>'bob')
    User.should_receive(:authenticate).with(user.login,"test").and_return user
    post :login, :user=>{ :login => user.login, :password => "test"}
    response.should be_redirect
    session[:user].should_not be_nil

    get :logout
    response.should be_redirect
    session[:user].should be_nil

    post :forgot_password, :user => {:email=>"notauser@doesntexist.com"}
    session[:user].should be_nil
    # flash[:warning].should == "Couldn't send password"
    response.should be_success
    response.should render_template("user/forgot_password")

    user = mock_model(User)
    User.should_receive(:find_by_email).with("exbob@mcbob.com").and_return(user)
    user.should_receive(:send_new_password).and_return(true)
    post :forgot_password, :user => {:email=>"exbob@mcbob.com"}
    session[:user].should be_nil
    response.should be_redirect
    response.should redirect_to(:action => 'login')
    # flash[:message].should == 'A new password has been sent by email.'
  end
end

describe UserController, 'user_home' do

  fixtures :users

  # it 'should not be accessible until logged in' do
    # get :user_home, :user_name => 'bob'
    # response.should be_success
    # flash[:warning].should be_nil
    # response.should render_template("user/other_user_home")
#
    # post :login, :user=>{ :login => "bob", :password => "test"}
    # response.should be_redirect
    # session[:user].should_not be_nil
#
    # get :user_home, :user_name => 'bob'
    # response.should be_success
    # flash[:warning].should be_nil
    # response.should render_template("user/user_home")
  # end
end

describe UserController, 'change_password' do

  fixtures :users

  it 'should work' do
=begin
    post :login, :user=>{ :login => "bob", :password => "test"}
    response.should be_redirect
    session[:user].should_not be_nil

    post :change_password, :user=>{ :password => "newpass", :password_confirmation => "newpassdoesntmatch"}
    response.should be_success
    #assert_invalid_column_on_record "user", "password"

    post :change_password, :user=>{ :password => "", :password_confirmation => ""}
    response.should be_success
    # assert_invalid_column_on_record "user", "password"

    post :change_password, :user=>{ :password => "newpass", :password_confirmation => "newpass"}
    response.should be_success
    # flash[:message].should == 'Password changed'
    response.should render_template("user/change_password")

    get :logout
    response.should be_redirect
    session[:user].should be_nil

    post :login, :user=> { :login => "bob", :password => "test" }
    response.should be_success
    session[:user].should be_nil
    # flash[:warning].should_not be_nil
    response.should render_template("user/login")

    post :login, :user=>{ :login => "bob", :password => "newpass"}
    response.should be_redirect
    session[:user].should_not be_nil
=end
  end
end
