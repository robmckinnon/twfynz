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
    # @months_top_pages = top_content 30
    @weeks_top_pages = top_content 7
    @days_top_pages = top_content 1
    @submission_dates = SubmissionDate.find_live_bill_submissions
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

  def self.title_from_path path
    case path.gsub('/',' ')
      when /^ debates (\d\d\d\d) (\S\S\S) (\d\d)$/
        date = DebateDate.new({:year=>$1,:month=>$2,:day=>$3})
        debates = Debate.find_by_date(date.year, date.month, date.day)
        if debates.first.is_a? OralAnswers
          "Questions for Oral Answer, #{date.to_date.as_date}"
        else
          "Parlimentary Debates, #{date.to_date.as_date}"
        end
      when /^ (bills|portfolios|committees) (\S+)$/
        about = $1.singularize.titleize.constantize.find_by_url($2)
        about.send("#{$1.singularize}_name")
      when /^ bills (\S+) submissions$/
        bill = Bill.find_by_url($1)
        "Submissions on #{bill.bill_name}"
      when /^ (bills|portfolios|committees) (\S+) (\d\d\d\d) (\S\S\S) (\d\d) (\S+)$/
        date = DebateDate.new({:year=>$3,:month=>$4,:day=>$5})
        debate = Debate.find_by_about_on_date_with_slug($1.singularize.titleize.constantize, $2, date, $6)
        if debate
          ($1 == 'bills') ? "#{debate.parent_name}, #{debate.name}" : debate.name
        else
          path
        end
      when /^ (\S+) (\d\d\d\d) (\S\S\S) (\d\d) (\S+)$/
        if Debate::CATEGORIES.include? $1
          date = DebateDate.new({:year=>$2,:month=>$3,:day=>$4})
          debate = Debate.find_by_url_category_and_url_slug(date, $1, $5)
          debate.parent_name ? "#{debate.parent_name}, #{debate.name}" : debate.name
        else
          path
        end
      else
        path
    end
  end

  private

    def top_content days
      report = Rugalytics.default_profile.load_report('TopContent', :from=>(Date.today - days) )
      items = report.items.delete_if{|i| (i.path[/\d\d\d\d/].nil? && !i.path[/bills\//]) || i.path[/search\?/] }.sort_by{|i| i.unique_page_views.to_i}.reverse
      items = items[0..9] if items.size > 10
      items.each do |item|
        item.path.sub!('mori','maori')
        item.url.sub!('mori','maori')
        item.page_title = ApplicationController.title_from_path item.path
      end
      items
    end

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
