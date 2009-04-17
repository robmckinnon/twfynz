def make_category_route path, map, action
  category = path.split('/').first
  map.method_missing "#{action}", path, :action => action.to_s, :url_category=>category
end

def make_route path, map, action=nil, options={}
  unless action
    parts = path.split('/')
    action = parts.last[/^:/] ? "show_#{parts.first.singularize}".to_sym : parts.last.split('.').first.to_sym
  end
  map.method_missing action, path, options.merge(:action => action.to_s)
end

def index_route path, map
  map.method_missing path.to_sym, path, :action => 'index'
end

def with_controller name, map
  map.with_options(:controller => name.to_s) { |sub_map| yield sub_map }
end

ActionController::Routing::Routes.draw do |map|

  single_date_format = { :date => /(19|20)\d\d-[0-1]?\d-[0-3]?\d/ }
  single_date_options = { :requirements => single_date_format }
  single_date_path = ':date'

  date_format = { :year => /(19|20)\d\d/,
                  :month => /(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec|[01]?\d|january|february|march|april|may|june|july|august|september|november|december)/,
                  :day => /[0-3]?\d/ }

  date_options = { :requirements => date_format, :month => nil, :day => nil }
  date_path = ':year/:month/:day'

  index_options = { :requirements => date_format.merge(:index => /[odw]?\d\d/) }
  index_path = "#{date_path}/:index"

  slug_format = {:url_slug => /[0-9a-z_-]+/}
  slug_options = { :requirements => date_format.merge(slug_format) }
  slug_path = "#{date_path}/:url_slug"

  category_format = { :url_category => /(#{Debate::CATEGORIES.join('|')}|debates)/ }
  category_options = { :requirements => date_format.merge(slug_format).merge(category_format), :url_slug => nil }

  category_on_date_options = { :requirements => date_format.merge(category_format), :month => nil, :day => nil }

  with_controller :application, map do |application|
    make_route '', application, :home
    make_route 'newspaper', application
    make_route 'about', application
    make_route 'contact', application
    make_route 'search', application
    make_route 'parliaments/:id', application, :parliament

    application.with_options(single_date_options) do |single_date|
      make_route single_date_path, single_date, :show_single_date
    end
  end

  with_controller :places, map do |place|
    index_route 'places', place
    make_route 'places/:name', place
  end

  with_controller :persisted_files, map do |pf|
    index_route 'persisted_files', pf
  end

  with_controller :portfolios, map do |portfolio|
    index_route 'portfolios', portfolio
    make_route 'portfolios/:portfolio_url', portfolio
    make_route 'portfolios/:portfolio_url/activity_sparkline.png', portfolio
  end

  with_controller :debates, map do |debate|
    index_route 'debates', debate
    make_route 'debates/contribution_match', debate

    debate.with_options(:requirements => category_format) do |by_category|
      make_route ":url_category", by_category, :show_debates_by_category
    end

    debate.with_options(category_on_date_options) do |by_date|
      category_path = ":url_category/#{date_path}"
      make_route category_path, by_date, :show_debates_on_date
    end

    debate.with_options(date_options) do |by_date|
      make_route "bills/:bill_url/#{date_path}", by_date, :show_bill_debates_on_date
      make_route "portfolios/:portfolio_url/#{date_path}", by_date, :show_portfolio_debates_on_date
      make_route "committees/:committee_url/#{date_path}", by_date, :show_committee_debates_on_date
    end

    debate.with_options(index_options) do |by_index|
      make_route "debates/#{index_path}", by_index, :redirect_show_debate
      make_route "bills/:bill_url/#{index_path}", by_index, :redirect_show_bill_debate
      make_route "portfolios/:portfolio_url/#{index_path}", by_index, :redirect_show_portfolio_debate
      make_route "committees/:committee_url/#{index_path}", by_index, :redirect_show_committee_debate
    end

    debate.with_options(category_options) do |by_category|
      category_path = ":url_category/#{date_path}/:url_slug"
      make_route category_path, by_category, :show_debate
    end

    debate.with_options(slug_options) do |by_slug|
      make_route "bills/:bill_url/#{slug_path}", by_slug, :show_bill_debate
      make_route "portfolios/:portfolio_url/#{slug_path}", by_slug, :show_portfolio_debate
      make_route "committees/:committee_url/#{slug_path}", by_slug, :show_committee_debate
    end

    make_route 'debates/search', debate, :debate_search
    make_route 'debates/search2', debate, :search
  end

  with_controller :bills, map do |bill|
    index_route 'bills', bill
    make_route 'bills/assented', bill
    make_route 'bills/negatived', bill
    make_route 'bills/:bill_url', bill
    make_route 'bills/:bill_url.atom', bill, :show_bill_atom
    make_route 'bills/:bill_url/submissions', bill, :show_bill_submissions
  end

  with_controller :mps, map do |mp|
    index_route 'mps', mp
    make_route 'mps/contribution_match', mp
    make_route 'mps/by_first', mp
    make_route 'mps/by_party', mp
    make_route 'mps/by_electorate', mp
    make_route 'mps/:name', mp
  end

  with_controller :donations, map do |donation|
    make_route 'donations/set_donation_organisation_slug/:id', donation, :set_donation_organisation_slug
    index_route 'donations', donation
    make_route 'donations/update/:id', donation, :update_donation
  end

  with_controller :committees, map do |committee|
    index_route 'committees', committee
    make_route 'committees/:committee_url', committee
  end

  with_controller :parties, map do |party|
    index_route 'parties', party
    make_route 'parties/third_reading_and_negatived_votes.:format', party, :third_reading_and_negatived_votes
    make_route 'parties/:name', party
    make_route 'parties/:name/:other_name', party, :compare_parties
  end

  map.resources :trackings
  map.resources :submissions

  with_controller :submissions, map do |submission|
    make_route 'submissions/set_submission_submitter_url/:id', submission, :set_submission_submitter_url
    make_route 'submissions/update/:id', submission, :update_submission
  end

  with_controller :organisations, map do |organisation|
    index_route 'organisations', organisation
    make_route 'organisations/create', organisation, :create_organisation
    make_route 'organisations/find', organisation, :find_organisation
    make_route 'organisations/new', organisation, :new_organisation
    make_route 'organisations/edit', organisation, :edit_organisations
    make_route 'organisations/:name', organisation
    make_route 'organisations/:name/edit', organisation, :edit_organisation
    make_route 'organisations/:name/update', organisation, :update_organisation
    make_route 'organisations/:name/mentions', organisation, :show_organisation_mentions
    make_route 'organisations/set_organisation_wikipedia_url/:id', organisation, :set_organisation_wikipedia_url
    make_route 'organisations/set_organisation_alternate_names/:id', organisation, :set_organisation_alternate_names
  end

  with_controller :user, map do |user|
    make_route 'users/signup', user, :signup
    make_route 'users/signup/individual', user, :signup_individual
    make_route 'users/signup/organisation', user, :signup_organisation
    make_route 'users/login', user
    make_route 'users/logout', user
    make_route 'users/forgot_password', user
    make_route 'users/change_password', user
    make_route 'user/:user_name.:format', user, :user_home
    make_route 'user/:user_name', user, :user_home
  end

  with_controller :kawaii, map do |x|
    index_route 'kawaii', x
    x.connect 'kawaii/:action/:id'
  end
end