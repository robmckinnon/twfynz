def make_category_route path, action, map
  make_route path, action, map, :category=>path.split('/').first
end

def make_route path, action, map, options={}
  map.method_missing action, path, options.merge(:action => action.to_s)
end

def index_route path, map
  map.method_missing path.to_sym, path, :action => 'index'
end

def with_controller name, map
  map.with_options(:controller => name.to_s) do |sub_map|
    yield sub_map
  end
end

ActionController::Routing::Routes.draw do |map|

  map.resources :submissions

  with_controller :submissions, map do |submission|
    make_route 'submissions/set_submission_submitter_url/:id', :set_submission_submitter_url, submission
    make_route 'submissions/update/:id', :update_submission, submission
  end

  with_controller :organisations, map do |organisation|
    index_route 'organisations', organisation
    make_route 'organisations/edit', :edit_organisations, organisation
    make_route 'organisations/:name', :show_organisation, organisation
    make_route 'organisations/:name/mentions', :show_organisation_mentions, organisation
    make_route 'organisations/set_organisation_wikipedia_url/:id', :set_organisation_wikipedia_url, organisation
    make_route 'organisations/set_organisation_alternate_names/:id', :set_organisation_alternate_names, organisation
  end

  map.resources :trackings

  date_format = { :year => /(19|20)\d\d/,
                  :month => /(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec|[01]?\d|january|february|march|april|may|june|july|august|september|november|december)/,
                  :day => /[0-3]?\d/ }

  date_options = { :requirements => date_format, :month => nil, :day => nil }
  date_path = ':year/:month/:day'

  index_options = { :requirements => date_format.merge(:index => /[odw]?\d\d/) }
  index_path = "#{date_path}/:index"

  slug_options = { :requirements => date_format.merge(:slug => /[a-z].+/) }
  slug_path = "#{date_path}/:slug"

  with_controller :application, map do |application|
    make_route '', :home, application
    make_route 'about', :about, application
    make_route 'contact', :contact, application
  end

  with_controller :places, map do |place|
    index_route 'places', place
    make_route 'places/:name', :show_place, place
  end

  with_controller :portfolios, map do |portfolio|
    index_route 'portfolios', portfolio
    make_route 'portfolios/:portfolio_url', :show_portfolio, portfolio
    make_route 'portfolios/:portfolio_url/activity_sparkline.png', :activity_sparkline, portfolio
  end

  with_controller :user, map do |user|
    make_route 'users/signup', :signup, user
    make_route 'users/signup/individual', :signup_individual, user
    make_route 'users/signup/organisation', :signup_organisation, user
    make_route 'users/login', :login, user
    make_route 'users/logout', :logout, user
    make_route 'users/forgot_password', :forgot_password, user
    make_route 'users/change_password', :change_password, user
    make_route 'user/:user_name.:format', :user_home, user
    make_route 'user/:user_name', :user_home, user
  end

  with_controller :debates, map do |debate|
    index_route 'debates', debate
    make_route 'debates/contribution_match', :contribution_match, debate

    categories = %w[visitors motions urgent_debates_declined points_of_order
        tabling_of_documents obituaries speakers_rulings personal_explanations
        appointments urgent_debates privilege speakers_statements resignations
        ministerial_statements adjournment parliamentary_service_commission]

    debate.with_options(date_options) do |by_date|
      make_route "debates/#{date_path}", :show_debates_on_date, by_date
      make_route "bills/:bill_url/#{date_path}", :show_bill_debates_on_date, by_date
      make_route "portfolios/:portfolio_url/#{date_path}", :show_portfolio_debates_on_date, by_date
      make_route "committees/:committee_url/#{date_path}", :show_committee_debates_on_date, by_date

      categories.each do |category|
        make_category_route "#{category}/#{date_path}", :show_debates_on_date, by_date
      end
    end

    debate.with_options(index_options) do |by_index|
      make_route "debates/#{index_path}",                   :show_debate, by_index
      make_route "bills/:bill_url/#{index_path}",           :show_bill_debate, by_index
      make_route "portfolios/:portfolio_url/#{index_path}", :show_portfolio_debate, by_index
      make_route "committees/:committee_url/#{index_path}", :show_committee_debate, by_index
    end

    debate.with_options(slug_options) do |by_slug|
      categories.each do |category|
        make_category_route "#{category}/#{slug_path}", :show_debate, by_slug
      end
    end

    make_route 'debates/search', :debate_search, debate
    make_route 'debates/search2', :search, debate
  end

  with_controller :bills, map do |bill|
    index_route 'bills', bill
    make_route 'bills/assented', :assented, bill
    make_route 'bills/negatived', :negatived, bill
    make_route 'bills/:bill_url', :show_bill, bill
    make_route 'bills/:bill_url/submissions', :show_bill_submissions, bill
  end

  with_controller :mps, map do |mp|
    index_route 'mps', mp
    make_route 'mps/contribution_match', :contribution_match, mp
    make_route 'mps/by_first', :by_first, mp
    make_route 'mps/by_party', :by_party, mp
    make_route 'mps/by_electorate', :by_electorate, mp
    make_route 'mps/:name', :mp, mp
  end

  with_controller :committees, map do |committee|
    index_route 'committees', committee
    make_route 'committees/:committee_url', :show_committee, committee
  end

  with_controller :parties, map do |party|
    index_route 'parties', party
    make_route 'parties/:name', :party, party
  end

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  # map.resources :products

  # Sample resource route with options:
  # map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  # map.resources :products, :has_many => [ :comments, :sales ], :has_ony => :seller

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # Install the default routes as the lowest priority.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end