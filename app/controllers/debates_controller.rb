class DebatesController < ApplicationController

  caches_action :index,
      :on_date, :portfolio_on_date, :committee_on_date, :bill_on_date,
      :show_debate, :show_portfolio_debate, :show_committee_debate, :show_bill_debate,
      :show_debates_on_date, :show_portfolio_debates_on_date, :show_committee_debates_on_date, :show_bill_debates_on_date

  layout "debates_layout"

  def index
    @hansard_on = true
    @recent_bill_debates = BillDebate.recent_grouped
    @recent_debates = Debate.recent
    @recent_qoa = OralAnswers.recent_grouped
  end

  def debate_search
    @term = params[:term]
    @term = params[:search_term] unless @term

    if @term == nil
      render :template => 'debates/search'
    else
      @count = Contribution.count_by_term @term
      @match_pages = Paginator.new self, @count, 10, params['page']
      @matches = Contribution.match_by_term @term, @match_pages

      if @matches.length > 0
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

    if @about.respond_to? :debate_topics and @about.debate_topics.size > 0
      debates += @about.debate_topics.collect {|t| t.debate }
    end

    if debates.size ==  0
      render :template => 'debates/show_about_debates_on_date'
    else
      # render :template => 'debates/question_about_search.rhtml'
      @debates_by_name, @names = Debate::get_debates_by_name debates

      render :template => 'debates/show_about_debates_on_date'
    end
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
    @date = DebateDate.new params
    if not @date.is_valid_date?
      redirect_url @date
    else
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
  end

  def show_debates_on_date
    @hansard_on = true
    @date = DebateDate.new params
    if not @date.is_valid_date?
      redirect_url @date
    else
      @calendar_date = @date.to_date
      debates = Debate.find_by_date(@date.year, @date.month, @date.day)

      @debates = Debate::remove_duplicates debates, false
      names = geonames_to_debates(@debates)
      @ni_map = make_map names, -38.2, 175
      @si_map = make_map names, -43.6, 170.3
      @debates.delete_if {|d| d.kind_of? SubDebate }
    end
  end

  def show_debate
    @hansard_on = true
    @organisations = Organisation.find(:all)
    @organisation_names = @organisations.collect(&:search_names)

    date = DebateDate.new params
    index = params[:index]
    index = index[1..2] if index.size == 3

    if not date.is_valid_date?
      redirect_url date
    else
      begin
        @debate = Debate.find_by_index(date.year, date.month, date.day, index)

        if @debate.is_a? SubDebate
          parent = @debate.debate
          # if (parent.sub_debates.size == 1 and not(parent.is_a?(OralAnswers)) )
            # redirect date, parent.index
          # else
            @parent = @debate.debate
            render :template => 'debates/show_subdebate'
          # end
        elsif @debate.is_a? DebateAlone
          render :template => 'debates/show_debate'
        elsif @debate.sub_debates.size > 1
          render :template => 'debates/show_debate_index'
        elsif @debate.is_a? OralAnswers
          render :template => 'debates/show_debate_index'
        end

      rescue ActiveRecord::RecordNotFound
        render :template => 'debates/debate_not_found', :status => "404 Not Found"
      end
    end
  end

  def show_bill_debate
    @hansard_on = true
    show_debate_about Bill, params[:bill_url]
  end

  def show_portfolio_debate
    @hansard_on = true
    show_debate_about Portfolio, params[:portfolio_url]
  end

  def show_committee_debate
    @hansard_on = true
    show_debate_about Committee, params[:committee_url]
  end

  private

    def show_debate_about about_type, url
      @organisations = Organisation.find(:all)
      @organisation_names = @organisations.collect(&:search_names)
      date = DebateDate.new params

      if not date.is_valid_date?
        redirect_url date
      else
        @about_type = about_type
        about = about_type.find_all_by_url(url)
        @hash = params
        type = about_type.to_s
        index = params[:index]

        debates = Debate::find_by_about(type, about.first.id, date.year, date.month, date.day, index)
        @debate = Debate::remove_duplicates(debates)[0]

        unless @debate
          debates = Debate::find_by_about(type, about.last.id, date.year, date.month, date.day, index)
          @debate = Debate::remove_duplicates(debates)[0]
        end

        if @debate
          @about = @debate.about
          @parent = @debate.debate
          render :template => 'debates/show_subdebate'
        else
          render :template => 'debates/debate_not_found'
        end
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
      params[:day] = date.day
      params[:month] = date.month
      redirect_to get_url_from_hash(params), :status=>:moved_permanently
    end

    def redirect date, index=nil
      if index
        redirect_to show_debate_url(:year => date.year, :month => date.month, :day => date.day, :index => index), :status=>:moved_permanently
      else
        redirect_to show_debates_on_date_url(:year => date.year, :month => date.month, :day => date.day), :status=>:moved_permanently
      end
    end

end

class DebateDate

  attr_reader :year, :month, :day, :hash

  MONTHS = ['january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december']
  MONTHS_ABBR = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']

  def initialize params
    @hash = params
    @year = params[:year]
    @month = params[:month]
    @day = params[:day]
  end

  def is_valid_date?
    @year.length == 4 and (!@month or @month.length == 3) and (!@day or @day.length == 2)
  end

  def month
    if @month and @month.length < 3
      Debate.mm_to_mmm @month
    elsif @month and @month.length > 3
      Debate.mm_to_mmm MONTHS.index(@month.downcase)+1
    else
      @month
    end
  end

  def day
    if @day and (@day.length == 1)
      '0'+@day
    else
      @day
    end
  end

  def strftime pattern
    if (pattern == "%d %b %Y" || pattern == "%d %B %Y")
      if @day
        to_date.strftime(pattern)
      elsif @month
        date = to_date.strftime pattern
        date = date.split(' ')
        date[1] + ' ' + date[2]
      else
        @year.to_s
      end
    elsif (@day and pattern == "%A")
      to_date.strftime(pattern)
    else
      ''
    end
  end

  def to_date
    month_number = MONTHS_ABBR.index(month) + 1 if @month

    if @day
      Date.new(@year.to_i, month_number, @day.to_i)
    elsif @month
      Date.new(@year.to_i, month_number, 1)
    else
      Date.new(@year.to_i, 1, 1)
    end
  end

end
