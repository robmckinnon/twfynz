class DebatesController < ApplicationController

  caches_action :index,
      :show_debate, :show_portfolio_debate, :show_committee_debate, :show_bill_debate,
      :show_debates_on_date, :show_portfolio_debates_on_date, :show_committee_debates_on_date, :show_bill_debates_on_date

  layout "debates_layout"

  before_filter :hansard_on,
      :only => [:index, :show_debates_on_date, :show_debate,
              :show_bill_debate, :show_portfolio_debate, :show_committee_debate]

  before_filter :load_organisations,
      :only => [:show_debate, :show_bill_debate, :show_portfolio_debate, :show_committee_debate]

  before_filter :validate_date,
      :only => [:show_debates_on_date, :show_debate,
              :show_bill_debate, :show_portfolio_debate, :show_committee_debate,
              :show_portfolio_debates_on_date, :show_committee_debates_on_date, :show_bill_debates_on_date]

  def index
    @recent_bill_debates = BillDebate.recent_grouped
    @recent_debates = Debate.recent
    @recent_qoa = OralAnswers.recent_grouped
  end

  def debate_search
    @term = params[:term]
    @term = params[:search_term] unless @term

    render :template => 'debates/search' and return if @term == nil

    @count = Contribution.count_by_term @term
    @match_pages = Paginator.new self, @count, 10, params['page']
    @matches = Contribution.match_by_term @term, @match_pages

    unless @matches.empty?
      @debate_ids = @matches.collect {|m| m.spoken_in_id}.uniq
      @by_debate = @matches.group_by {|m| m.spoken_in_id}

      debates = []
      @debate_ids.each_with_index {|id,i| debates[i] = Debate.find(id)}

      debates = Debate::remove_duplicates debates
      debates.sort! { |a,b| b.date <=> a.date }

      @debate_ids = debates.collect { |d| d.id }

      @debates = {}
      @debate_ids.each_with_index {|id,i| @debates[id] = debates[i]}

      render :template => 'debates/search'
    else
      flash[:term] = @term
      render :template => 'debates/search_form'
    end
  end

  def contribution_match
    @contribution_match = Contribution.find(params[:id])
    render :partial => 'contribution_match', :locals => {:expand => params[:expand], :term => params[:term]}
  end

  def search
    term = params[:term]
    term = params[:search_term] unless term

    if request.post? and term and term.size > 0
      redirect_to debate_search_url(:term => term)
    else
      render :template => 'debates/search_form'
    end
  end

  def about_search about_type, url
    @about = about_type.find_by_url url
    @about_type = about_type
    @hash = params
    debates = Debate.find_by_about about_type.name, @about.id, nil, nil, nil, nil

    if @about.respond_to? :debate_topics && @about.debate_topics.size > 0
      debates += @about.debate_topics.collect {|t| t.debate }
    end

    @debates_by_name, @names = Debate::get_debates_by_name debates unless debates.empty?
    render :template => 'debates/show_about_debates_on_date'
  end

  def show_portfolio_debates_on_date
    @portfolios_on = true
    show_about_debates_on_date Portfolio, params[:portfolio_url]
  end

  def show_committee_debates_on_date
    @committees_on = true
    show_about_debates_on_date Committee, params[:committee_url]
  end

  def show_bill_debates_on_date
    @bills_on = true
    show_about_debates_on_date Bill, params[:bill_url]
  end

  def show_about_debates_on_date about_type, url
    debates = Debate.find_by_about_on_date about_type, url, @date
    @hash = params
    @about_type = about_type
    @about = about_type.find_by_url url
    if (@about.respond_to? :debate_topics and @about.debate_topics.size > 0)
      debates += @about.debate_topics.collect {|t| t.debate }
    end

    @debates_by_name, @names = Debate::get_debates_by_name debates

    render :template => 'debates/show_about_debates_on_date'
  end

  def show_debates_on_date
    @calendar_date = @date.to_date
    debates = Debate.find_by_date(@date.year, @date.month, @date.day)

    @debates = Debate::remove_duplicates debates, false
    names = geonames_to_debates(@debates)
    @ni_map = make_map names, -38.2, 175
    @si_map = make_map names, -43.6, 170.3
    @debates.delete_if {|d| d.kind_of? SubDebate }
  end

  def show_debate
    begin
      render_debate Debate.find_by_date_and_index(@date, index_id(params))
    rescue ActiveRecord::RecordNotFound
      render :template => 'debates/debate_not_found', :status => "404 Not Found"
    end
  end

  def show_bill_debate
    show_debate_about Bill, params[:bill_url]
  end

  def show_portfolio_debate
    show_debate_about Portfolio, params[:portfolio_url]
  end

  def show_committee_debate
    show_debate_about Committee, params[:committee_url]
  end

  private

    def hansard_on
      @hansard_on = true
    end

    def load_organisations
      @organisations = Organisation.find(:all)
      @organisation_names = @organisations.collect(&:search_names)
    end

    def validate_date
      @date = DebateDate.new params
      redirect_url @date unless @date.is_valid_date?
    end

    def index_id params
      params[:index].size == 3 ? params[:index][1..2] : params[:index]
    end

    def render_debate debate
      @debate = debate
      case @debate
        when SubDebate
          @parent = @debate.debate
          render :template => 'debates/show_subdebate'
        when DebateAlone
          render :template => 'debates/show_debate'
        else
          render :template => 'debates/show_debate_index' if @debate.sub_debates.size > 1 || @debate.is_a?(OralAnswers)
      end
    end

    def show_debate_about about_type, about_url
      @debate = Debate.find_by_about_on_date_with_index about_type, about_url, @date, params[:index]
      @about_type = about_type
      @hash = params

      if @debate
        @about = @debate.about
        @parent = @debate.debate
        render :template => 'debates/show_subdebate'
      else
        render :template => 'debates/debate_not_found'
      end
    end

    def get_url_from_hash hash
      is_index = (hash.has_key?(:index) and (not hash[:index].nil?))

      if hash.has_key? :portfolio_url
        is_index ? show_portfolio_debate_url(hash) : show_portfolio_debates_on_date_url(hash)
      elsif hash.has_key? :committee_url
        is_index ? show_committee_debate_url(hash) : show_committee_debates_on_date_url(hash)
      elsif hash.has_key? :bill_url
        is_index ? show_bill_debate_url(hash) : show_bill_debates_on_date_url(hash)
      else
        is_index ? show_debate_url(hash) : show_debates_on_date_url(hash)
      end
    end

    def redirect_url date
      params.merge! :day => date.day, :month => date.month
      redirect_to get_url_from_hash(params), :status => :moved_permanently
    end
end
