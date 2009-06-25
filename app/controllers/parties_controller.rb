class PartiesController < ApplicationController

  caches_action :index, :show_party, :third_reading_and_negatived_votes, :compare_parties

  layout "parties_layout"

  def index
    @parties = Party.all_size_ordered
    @title = "Parties in Aotearoa New Zealand's Parliament"
    @total_mps_48 = @parties.inject(0) {|count, p| count + p.mp_count(48) }
    @total_mps_49 = @parties.inject(0) {|count, p| count + p.mp_count(49) }
    @third_reading_matrix = Vote.third_reading_matrix
  end

  def compare_parties
    params[:parliament_number] = Parliament.latest.id
    compare_parties_by_parliament
  end

  def compare_parties_by_parliament
    party_name = params[:name]
    other_party_name = params[:other_name]
    parliament_number = params[:parliament_number]

    @parliament = Parliament.find(parliament_number)
    @party = Party::get_party party_name
    @other_party = Party::get_party other_party_name
    if @party && @other_party && @parliament
      # @aye_votes_together = @party.aye_votes_together(@other_party)
      # @noe_votes_together = @party.noe_votes_together(@other_party)
      @aye_votes_together, @noe_votes_together, @ayes_noes, @noes_ayes, @abstentions_abstentions, @ayes_abstentions, @noes_abstentions, @abstentions_ayes, @abstentions_noes, @novote_novote, @ayes_novote, @noes_novote, @abstentions_novote, @novote_ayes, @novote_noes, @novote_abstentions = @party.votes_comparison(@other_party, parliament_number)
      @voted_same_way_count = @aye_votes_together.size + @noe_votes_together.size + @abstentions_abstentions.size + @novote_novote.size
      @voted_different_way_count = @ayes_noes.size + @noes_ayes.size + @ayes_abstentions.size + @noes_abstentions.size + @abstentions_ayes.size + @abstentions_noes.size + @ayes_novote.size + @noes_novote.size + @abstentions_novote.size + @novote_ayes.size + @novote_noes.size + @novote_abstentions.size
      @total_count = @voted_same_way_count + @voted_different_way_count
      @voted_same_way_percent = @voted_same_way_count / @total_count.to_f * 100
      @voted_different_way_percent = @voted_different_way_count / @total_count.to_f * 100
      render :template => 'parties/compare_parties'
    else
      redirect_to :controller=>'application', :action=>'home'
    end
  end

  def show_party
    party = Party::get_party params[:name]

    if party
      @name = party.name
      @bills_in_charge_of = party.bills_in_charge_of

      parliament = Parliament.find(48)
      party_in_parliament = party.in_parliament(48)

      if party_in_parliament
        @total_party_votes_size = parliament.party_votes_count
        @party_votes_size = party_in_parliament.party_votes_count
        @party_vote_percent = @party_votes_size * 100.0 / @total_party_votes_size

        @total_bill_votes_size = parliament.bill_final_reading_party_votes_count
        @bill_votes_size = party_in_parliament.bill_final_reading_party_votes_count
        @bill_vote_percent = @bill_votes_size * 100.0 / @total_bill_votes_size
      else
        @party_votes_size = 0
      end

      @party = party
    else
      render(:template => 'parties/invalid_party', :status => 404)
    end
  end

  def contribution_match
    @recent_contribution = Contribution.find(params[:id])
    render :partial => 'recent_contribution', :locals => {:expand => params[:expand]}
  end

  def third_reading_and_negatived_votes
    @title = 'Bill third reading and negatived votes data'
    text = []
    Parliament.find_each do |parliament|
      html = "<a href='#{third_reading_and_negatived_votes_by_parliament_url(:id=>parliament.id, :format=>'csv')}'>#{parliament.ordinal} Parliament bill votes CSV</a>"
      html += " (#{format_date(parliament.commission_opening_date)} - "
      html += "#{parliament.dissolution_date ? format_date(parliament.dissolution_date) : format_date(Date.today)}"
      html += ")"
      text << html
    end
    render :text => "<h1>#{@title}</h1><p>#{text.join('</p><p>')}</p>", :layout => 'parties_layout'
    # redirect_to third_reading_and_negatived_votes_by_parliament_url(:id => Parliament.latest.id)
  end
end
