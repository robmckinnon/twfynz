class Parliament < ActiveRecord::Base

  has_many :members, :include => [:person, :party]
  belongs_to :commission_opening_debate, :class_name=>'Debate', :foreign_key=>'commission_opening_debate_id'

  class << self
    def dissolution_date parliament_id
      @dissolution_dates ||= []
      unless @dissolution_dates[parliament_id]
        @dissolution_dates[parliament_id] = Parliament.find(parliament_id).dissolution_date
      end
      @dissolution_dates[parliament_id]
    end

    def date_within? parliament_id, date
      find(parliament_id).date_within? date
    end
  end

  def in_parliament list
    list.select {|item| item.date >= commission_opening_date && item.date <= dissolution_date}
  end

  def populate_party_vote_counts
    self.bill_final_reading_party_votes_count = Vote.third_reading_and_negatived_votes.size
    self.party_votes_count = PartyVote.all_unique.size
  end

  def date_within? date
    if commission_opening_date && dissolution_date
      if commission_opening_date <= date && date <= dissolution_date
        true
      else
        false
      end
    elsif commission_opening_date && commission_opening_date <= date
      true
    else
      false
    end
  end

  def populate_48th_members
    Member.find(:all, :conditions=>'from_date >= "2005-11-07"').each do |m|
      m.parliament_id = 48
      m.save
    end
  end
end
