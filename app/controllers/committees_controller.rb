class CommitteesController < ApplicationController

  caches_action :index, :show_committee

  layout "committees_layout"

  def index
    @committees_on = true
    @committees = Committee.find(:all).group_by {|b| b.url}
    # @committees_with_debates = Committee.find_all_with_debates.group_by {|b| b.url}
    # @committees_without_debates = Committee.find_all_without_debates.group_by {|b| b.url}
  end

  def show_committee
    @committees_on = true
    name = params[:committee_url]
    @committee = Committee.find_by_url(name, :include => [:bills, :sub_debates])

    @hash = params

    if @committee
      @debates = Debate.find_all_by_about_type_and_about_id(Committee.name, @committee.id)

      if @debates.size > 0
        @debates_in_groups_by_name = Debate.debates_in_groups_by_name @debates
      end
      @bills_before_committee = @committee.bills_before_committee
      @bills = @committee.reported_bills_current
      @negatived = @committee.reported_bills_negatived
      @assented = @committee.reported_bills_assented
    end
  end

end
