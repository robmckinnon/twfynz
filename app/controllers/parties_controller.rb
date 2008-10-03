class PartiesController < ApplicationController

  caches_action :index, :party

  layout "parties_layout"

  def index
    @parties = Party.all_size_ordered
    @title = "Parties in Aotearoa New Zealand's Parliament"
    @total_mps = @parties.inject(0) {|count, p| count + p.mps.size }
    @third_reading_matrix = Vote.third_reading_matrix
    @ayes_third_reading_matrix = Vote.third_reading_matrix :ayes
    @noes_third_reading_matrix = Vote.third_reading_matrix :noes
  end

  def compare_parties
    @party = Party::get_party params[:name]
    @other_party = Party::get_party params[:other_name]
    @votes_together = @party.votes_together(@other_party)
  end

  def show_party
    party = Party::get_party params[:name]

    if party
      @name = party.name
      # @recent_contributions = party.recent_contributions
      # @subjects_asked_about = []
      # @subjects_answered_about = []
      # @portfolios_asked_about = []
      # @portfolios_answered_about = []
      @bills_in_charge_of = party.bills_in_charge_of

      @party = party
    else
      render(:template => 'parties/invalid_party', :status => 404)
    end
  end

  def contribution_match
    @recent_contribution = Contribution.find(params[:id])
    render :partial => 'recent_contribution', :locals => {:expand => params[:expand]}
  end

end
