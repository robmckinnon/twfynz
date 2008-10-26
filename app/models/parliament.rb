class Parliament < ActiveRecord::Base

  belongs_to :commission_opening_debate, :class_name=>'Debate', :foreign_key=>'commission_opening_debate_id'

  def populate_party_vote_counts
    self.bill_final_reading_party_votes_count = Vote.third_reading_and_negatived_votes.size
    self.party_votes_count = PartyVote.all_unique.size
  end
end
