class Party < ActiveRecord::Base

  has_many :mps, :foreign_key => 'member_of_id'

  has_many :vote_casts
  has_many :votes, :through => :vote_casts

  class << self
    def from_vote_name name
      party = find_by_vote_name(name)
      unless party
        party = find_by_short(name)
      end
      party
    end

    def all_size_ordered
      find(:all, :include => :mps).sort {|a,b| b.mps.size <=> a.mps.size}
    end

    def get_party name
      find(:all, :include => {:mps=>:bills}).select {|p| p.id_name == name}.first
    end

    def find_all_sorted
      find(:all).sort{|a,b| b.mp_count <=> a.mp_count}
    end

    def mp_count
      find_all_sorted.collect do |party|
        [party.short, party.mp_count]
      end
    end

    def colours
      find_all_sorted.collect {|p| '#'+p.colour}
    end
  end

  def wordle_text
    name = "#{short}~words"
    Debate.wordlize_text mps.collect{|mp| mp.unique_contributions.collect(&:wordle_text)}.flatten.join("\n"), name, 1.1
  end

  def mp_count
    mps.size
  end

  def id_name
    short.downcase.gsub(' ','_')
  end

  def abbreviated
    abbreviation.blank? ? name : abbreviation
  end

  def recent_contributions
    contributions = []
    mps.each do |mp|
      contributions += mp.recent_contributions
    end

    Oration.recent_contributions contributions, id, Party
  end

  def bills_in_charge_of
    bills = []
    mps.each do |mp|
      bills += mp.bills_in_charge_of
    end

    bills.sort {|a,b| a.bill_name <=> b.bill_name}
  end

  def three_letter
    case short
      when 'ACT'           then 'ACT'
      when 'Green'         then 'Grn'
      when 'Labour'        then 'Lab'
      when 'Maori Party'   then 'MP'
      when 'National'      then 'Nat'
      when 'NZ First'      then 'NZF'
      when 'Progressive'   then 'Prg'
      when 'United Future' then 'UF'
      else 'Oth'
    end
  end
end
