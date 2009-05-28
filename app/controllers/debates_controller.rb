class DebatesController < ApplicationController

  caches_action :index,
      :show_debate, :show_portfolio_debate, :show_committee_debate, :show_bill_debate,
      :show_debates_on_date, :show_portfolio_debates_on_date, :show_committee_debates_on_date, :show_bill_debates_on_date

  layout "debates_layout"

  before_filter :hansard_on,
      :only => [:index, :show_debates_on_date, :show_debate,
              :show_bill_debate, :show_portfolio_debate, :show_committee_debate]

  before_filter :load_organisations, :reset_speaker_anchors,
      :only => [:show_debate, :show_bill_debate, :show_portfolio_debate, :show_committee_debate]

  before_filter :validate_date,
      :only => [:show_debates_on_date, :show_debate, :redirect_show_debate,
              :show_bill_debate, :show_portfolio_debate, :show_committee_debate,
              :redirect_show_bill_debate, :redirect_show_portfolio_debate, :redirect_show_committee_debate,
              :show_portfolio_debates_on_date, :show_committee_debates_on_date, :show_bill_debates_on_date]

  before_filter :redirect_if_required, :only => [:show_debate]

  def index
    @recent_bill_debates = BillDebate.recent_grouped
    @recent_debates = Debate.recent
    @recent_qoa = OralAnswers.recent_grouped
    @all_recent = @recent_qoa + @recent_debates + @recent_bill_debates
    @all_recent.sort! do |a,b|
      a = a.first if a.is_a?(Array)
      b = b.first if b.is_a?(Array)
      a_title = (a.is_a?(OralAnswer) && a.about) ? a.about.full_name : a.name
      b_title = (b.is_a?(OralAnswer) && b.about) ? b.about.full_name : b.name
      a_title <=> b_title
    end
  end

  def debate_search
    @term = params[:term]
    @term = params[:search_term] unless @term

    render :template => 'debates/search' and return if @term == nil

    page = params['page'] || 1
    @entries = WillPaginate::Collection.create(page, 10) do |pager|
      @matches, @count = Contribution.match_by_term(@term, pager.per_page, pager.offset)
      pager.replace(@matches)
      pager.total_entries = @count
    end

    unless @matches.empty?
      @debate_ids = @matches.collect(&:spoken_in_id).uniq
      debates = []
      @debate_ids.each_with_index {|id,i| debates[i] = Debate.find(id)}
      debates = Debate::remove_duplicates debates
      debates.sort! { |a,b| b.date <=> a.date }

      @debate_ids = debates.collect(&:id)
      @debates = {}
      @debate_ids.each_with_index {|id,i| @debates[id] = debates[i]}

      @by_debate = @matches.group_by(&:spoken_in_id)
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

    @debates_in_groups_by_name = Debate.debates_in_groups_by_name debates unless debates.empty?
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

  def show_debates_by_category
    @category = params[:url_category]
    @debates = Debate.find_with_url_category(@category)
  end

  def show_about_debates_on_date about_type, url
    debates = Debate.find_by_about_on_date about_type, url, @date
    @hash = params
    @about_type = about_type
    @about = about_type.find_by_url url
    if (@about.respond_to? :debate_topics and @about.debate_topics.size > 0)
      debates += @about.debate_topics.collect {|t| t.debate }
    end

    @debates_in_groups_by_name = Debate.debates_in_groups_by_name debates

    render :template => 'debates/show_about_debates_on_date'
  end

  def show_debates_on_date
    @debates = Debate.find_by_date(@date.year, @date.month, @date.day)

    if (category = params[:url_category]) && (category != 'debates')
      @debates = @debates.select{|d| d.url_category == category}
      single_debate_identified = @date.day && @debates.size == 1 && @debates.first.url_slug.blank?

      if single_debate_identified
        load_organisations
        show_debate
      else
        @category = category
      end
    else
      @debates.delete_if {|d| d.kind_of? SubDebate }
      @category = 'debates'
    end

    names = geonames_to_debates(@debates)
    @ni_map = make_map names, -38.2, 175
    @si_map = make_map names, -43.6, 170.3
    @calendar_date = @date.to_date
  end

  def redirect_show_debate
    begin
      debate = Debate.find_by_date_and_index(@date, index_id(params))
      redirect_to get_url_from_hash(debate.id_hash)
    rescue ActiveRecord::RecordNotFound
      render_debate_not_found
    end
  end

  def show_debate
    begin
      @admin = admin?
      debate = Debate.find_by_url_category_and_url_slug(@date, params[:url_category], params[:url_slug])
      debate ? render_debate(debate) : render_debate_not_found
    rescue ActiveRecord::RecordNotFound
      render_debate_not_found
    end
  end

  def redirect_show_bill_debate
    redirect_show_debate_about Bill, params[:bill_url]
  end

  def redirect_show_portfolio_debate
    redirect_show_debate_about Portfolio, params[:portfolio_url]
  end

  def redirect_show_committee_debate
    redirect_show_debate_about Committee, params[:committee_url]
  end

  def show_bill_debate
    show_debate_about Bill, params[:bill_url], params[:url_slug]
  end

  def show_portfolio_debate
    show_debate_about Portfolio, params[:portfolio_url], params[:url_slug]
  end

  def show_committee_debate
    show_debate_about Committee, params[:committee_url], params[:url_slug]
  end

  private

    def hansard_on
      @hansard_on = true
    end

    def reset_speaker_anchors
      SpeakerName.reset_anchors
    end

    def load_organisations
      @organisations = Organisation.find(:all)
      @organisation_names = @organisations.collect(&:search_names)
    end

    def redirect_if_required
      if params[:url_category] == 'obituaries'
        if %w[rt_hon_david_russell_lange_onz_ch john_finlay_luxton_qso hon_john_howard_falloon_cnzm rod_david_donald].include?(params[:url_slug])
          redirect_to get_url_from_hash(params.merge(:url_slug => 'lange_luxton_falloon_donald')), :status => :moved_permanently
        end
      end
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

    def redirect_show_debate_about about_type, about_url
      begin
        debate = Debate.find_by_about_on_date_with_index about_type, about_url, @date, params[:index]
        redirect_to get_url_from_hash(debate.id_hash)
      rescue ActiveRecord::RecordNotFound
        render_debate_not_found
      end
    end

    def show_debate_about about_type, about_url, url_slug
      @debate = Debate.find_by_about_on_date_with_slug about_type, about_url, @date, url_slug
      @about_type = about_type
      @hash = params

      if @debate
        @about = @debate.about
        @parent = @debate.debate
        render :template => 'debates/show_subdebate'
      else
        render_debate_not_found
      end
    end

    def get_url_from_hash hash
      has_slug = !hash[:url_slug].blank?

      if hash.has_key? :portfolio_url
        has_slug ? show_portfolio_debate_url(hash) : show_portfolio_debates_on_date_url(hash)
      elsif hash.has_key? :committee_url
        has_slug ? show_committee_debate_url(hash) : show_committee_debates_on_date_url(hash)
      elsif hash.has_key? :bill_url
        has_slug ? show_bill_debate_url(hash) : show_bill_debates_on_date_url(hash)
      else
        has_slug ? show_debate_url(hash) : show_debates_on_date_url(hash)
      end
    end

    def redirect_url date
      params.merge! :day => date.day, :month => date.month
      redirect_to get_url_from_hash(params), :status => :moved_permanently
    end

    def render_debate_not_found
      render :template => 'debates/debate_not_found', :status => "404 Not Found"
    end
end
