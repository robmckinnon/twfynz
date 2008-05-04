# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  before_filter :remove_trailing_slash

  before_filter :user_login_flash
  after_filter :user_login_flash

  include CacheableFlash
  before_filter :write_flash_to_cookie

  # prevent any field that matches /password/ from being logged
  filter_parameter_logging "password"

  caches_action :home, :about, :contact

  layout "application"

  def home
    render :template => 'home'
  end

  def about
    render :template => 'about'
  end

  def contact
    render :template => 'contact'
  end

  def logged_in
    if current_user
      true
    else
      flash[:warning] = 'Please login to continue'
      session[:return_to] = request.request_uri
      redirect_to :controller => "user", :action => "login"
      false
    end
  end

  def current_user
    session[:user]
  end

  def redirect_to_stored
    if return_to = session[:return_to]
      session[:return_to] = nil
      redirect_to return_to
    else
      redirect_to :controller => 'user', :action => 'user_home', :user_name => current_user.login
    end
  end

  def flash_js
    render(:file=> 'javascript/flash.js' )
  end

  def admin?
    current_user && current_user.login == 'rob'
  end

  private

    def site_url
      host = request.host_with_port.include?('80') ? request.host : request.host_with_port
      request.protocol + host
    end

    def user_login_flash
      site = site_url
      if current_user
        user_url = site + '/user/' + current_user.login
        logout_url = site + '/users/logout'

        flash[:login_form] = ' '
        flash[:logged_in] = '' +
            %Q[<span>Welcome, <a href="#{user_url}">#{current_user.login}</a></span> | ] +
            %Q[<span><a href="#{logout_url}">Sign out</a></span>]
      else
        sign_up_url = site + '/users/signup'
        login_url = site + '/users/login'
        log_in_links = '' +
            %Q[<span><a title="User sign up" href="#{sign_up_url}">Sign up</a></span> or ] +
            %Q[<span><a title="User login" href="#{login_url}">login</a></span>]
        # flash[:logged_in] = log_in_links
        flash[:logged_in] = ' '
      end
    end

    def remove_trailing_slash
      uri = request.request_uri
      if uri.length > 1 and uri[-1,1] == '/'
        uri = request.protocol + request.host + uri.chop
        redirect_to uri,
        headers['Status'] = '301 Moved Permanently'
      end
    end

    def marker geoname, debates
      debate_links = debates.collect { |debate| render_to_string(:partial => 'debates/map_debate_link', :object => debate) }

      GMarker.new([geoname.latitude,geoname.longitude],
          :title => geoname.name,
          :info_window =>
              '<strong>' + geoname.name + '</strong><ul>' +
              debate_links.join('')+'</ul>'
          )
    end

    def make_map geonames_to_debates, lat, long, zoom=6
      if RAILS_ENV == 'test' || RAILS_ENV == 'development' || RAILS_ENV == 'production'
        return nil
      end
      map = GMap.new("map_div")
      if map
        map.control_init(:large_map => true,:map_type => true)
        map.center_zoom_init([lat, long], zoom)
        geonames_to_debates.each do |geoname, debates|
          map.record_init map.add_overlay(marker(geoname, debates))
        end
      end
      map
    end

    def geonames_to_debates debates
      debate_geonames = debates.collect{ |d| [d, d.geonames] }
      names_to_debates = {}

      debate_geonames.each do |item|
        debate = item[0]
        geonames = item[1]

        geonames.each do |geoname|
          names_to_debates[geoname] = [] unless names_to_debates.has_key?(geoname)
          names_to_debates[geoname] << debate
        end
      end

      names_to_debates
    end
end
