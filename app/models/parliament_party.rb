class ParliamentParty < ActiveRecord::Base
  belongs_to :party
  belongs_to :parliament

  class << self
    def populate parliament_no
      parties = ParliamentParty.all.select {|x| x.parliament.id == parliament_no}
      parties.each do |x|
        x.populate_party_vote_counts
        x.save
        nil
      end
      parliament = Parliament.find(parliament_no)
      parliament.populate_party_vote_counts
      parliament.save
      nil
    end
  end

  def populate_party_vote_counts
    self.bill_final_reading_party_votes_count = party.bill_third_reading_and_negatived_votes(parliament_id).size
    votes = party.party_votes(parliament_id)
    # votes = votes.group_by{|v| v.debate.id}.to_a.collect {|d, list| list.first}.flatten
    self.party_votes_count = votes.size
  end

end
