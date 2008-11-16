class Parliament < ActiveRecord::Base

  has_many :members, :include => [:person, :party]
  belongs_to :commission_opening_debate, :class_name=>'Debate', :foreign_key=>'commission_opening_debate_id'

  def in_parliament list
    list.select {|item| item.date >= commission_opening_date && item.date <= dissolution_date}
  end

  def populate_party_vote_counts
    self.bill_final_reading_party_votes_count = Vote.third_reading_and_negatived_votes.size
    self.party_votes_count = PartyVote.all_unique.size
  end

  def populate_48th_members
    Member.find(:all, :conditions=>'from_date >= "2005-11-07"').each do |m|
      m.parliament_id = 48
      m.save
    end
  end
end
