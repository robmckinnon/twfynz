class ParliamentParty < ActiveRecord::Base
  belongs_to :party
  belongs_to :parliament

  def populate_party_vote_counts
    self.bill_final_reading_party_votes_count = party.bill_third_reading_and_negatived_votes.size
    self.party_votes_count = party.party_votes.size
  end

end
