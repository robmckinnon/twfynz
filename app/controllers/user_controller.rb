class UserController < ApplicationController

  before_filter :logged_in, :only=>['change_password', 'hidden']

  layout "user_layout"

  def signup
    if request.post?
      user_type = params[:user_type]

      if user_type == 'individual'
        redirect_to :action => 'signup_individual'
      elsif user_type == 'organisation'
        redirect_to :action => 'signup_organisation'
      end
    end
  end

  def signup_individual
    @user = User.new(params[:user]) #shouldn't there be more params used here?
    if request.post?
      if @user.save
        session[:user] = User.authenticate(@user.login, @user.password)
        flash[:message] = "Signup successful"
        redirect_to :action => "user_home", :user_name => @user.login
      else
        flash[:warning] = "Signup unsuccessful"
        render :template => 'user/signup_individual'
      end
    elsif current_user
      @user = current_user
      redirect_to :action => "user_home", :user_name => @user.login
    end
  end

  def login
    if request.post?
      if (session[:user] = User.authenticate(params[:user][:login], params[:user][:password]) )
        flash[:message]  = "Login successful"
        redirect_to_stored
      else
        flash[:warning] = "Login unsuccessful"
      end
    elsif current_user
      @user = current_user
      redirect_to :action => "user_home", :user_name => @user.login
    end
  end

  def logout
    session[:user] = nil
    flash[:message] = 'Logged out'
    redirect_to :controller => 'application', :action => 'home'
  end

  def forgot_password
    if request.post?
      user = User.find_by_email(params[:user][:email])
      if user and user.send_new_password
        flash[:message]  = "A new password has been sent by email."
        redirect_to :action=>'login'
      else
        flash[:warning]  = "Couldn't send password"
      end
    end
  end

  def change_password
    @user = session[:user]
    if request.post?
      @user.update_attributes(:password => params[:user][:password],
          :password_confirmation => params[:user][:password_confirmation])
      if @user.save
        flash[:message]="Password changed"
      end
    end
  end

  def user_home
    @user_name = params[:user_name]

    if (current_user and current_user.login == @user_name)
      @tracked_items = current_user.tracked_items
      respond_to do |format|
        format.html { render :template => 'user/user_home' }
        format.atom { render :template => 'user/user_home.atom.haml', :layout => false }
      end
    elsif (user = User.find_by_login(@user_name))
      @tracked_items = user.tracked_items

      respond_to do |format|
        format.html { render :template => 'user/other_user_home' }
        format.atom { render :template => 'user/user_home.atom.haml', :layout => false }
      end
    else
      render :template => 'user/user_not_found'
    end
  end

  def hidden
  end

  def delete

  end

  def edit

  end

end
