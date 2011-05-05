class MpsController < ApplicationController

  caches_action :index, :by_first, :by_party, :by_electorate, :show_mp

  layout "mps_layout"

  def index
    @by_last = true
    @mps = Mp.all_by_last
  end

  def by_first
    @by_first = true
    @mps = Mp.all_by_first
    render :template => 'mps/index'
  end

  def by_electorate
    @by_electorate = true
    @mps = Mp.all_by_electorate
    render :template => 'mps/index'
  end

  def by_party
    @by_party = true
    @mps = Mp.all_by_party
    render :template => 'mps/index'
  end

  def show_mp
    name = params[:name]
    mp = Mp.find_by_id_name name

    if mp
      @party = mp.party.abbreviated if mp.party
      @name = %Q[#{mp.first} #{mp.last}]
      @former_mp = mp.is_former?
      @electorate = mp.electorate
      # logger.info('*** recent')
      @recent_contributions = mp.recent_contributions
      # logger.info('*** subjects_asked_about')
      @subjects_asked_about = mp.subjects_asked_about
      # logger.info('*** subjects_answered_about')
      @subjects_answered_about = mp.subjects_answered_about
      # logger.info('*** portfolios_asked_about')
      @portfolios_asked_about = mp.portfolios_asked_about
      # logger.info('*** portfolios_answered_about')
      @portfolios_answered_about = mp.portfolios_answered_about
      @pecuniary_interests_by_category = mp.pecuniary_interests_by_category
      @bills_in_charge_of = mp.bills_in_charge_of

      if mp.is_former?
        @role_description = 'Former MP'
      elsif @electorate != 'List'
        @role_description = "Member for #{@electorate}, #{@party}"
      else
        @role_description = %Q[List member, #{@party}]
      end
      @mp = mp
      @member_role = mp.member_on_date(Date.today)
      @former_member_role = (mp.members - [@member_role]).sort_by(&:parliament_id).last if @member_role.nil? || @member_role.party.short == 'Independent'
      @membership_role_change = mp.members.select {|m| m.membership_change_url}.sort_by(&:parliament_id).last
    elsif name == 'ian_ewen_street'
      headers["Status"] = "301 Moved Permanently"
      redirect_to show_mp_url(:name => 'ian_ewen-street')
    elsif name == 'david_benson_pope'
      headers["Status"] = "301 Moved Permanently"
      redirect_to show_mp_url(:name => 'david_benson-pope')
    else
      render(:template => 'mps/invalid_mp', :status => 404)
    end
  end

  def contribution_match
    @recent_contribution = Contribution.find(params[:id])
    render :partial => 'recent_contribution', :locals => {:expand => params[:expand]}
  end

  def search_mp
    mps = Mp.find(:all, :order => "last")
    name = request.raw_post || request.query_string
    matcher = Regexp.new(name)
    # names = @mps.collect {|mp| mp.downcase_name}
    mps = mps.find_all { |mp| mp.downcase_name =~ matcher }
    @results = mps.collect { |mp| mp.full_name }
    render(:layout => false)
  end

end
