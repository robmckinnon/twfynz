class Party < ActiveRecord::Base

  has_many :mps, :foreign_key => 'member_of_id'

  has_many :donations

  has_many :vote_casts
  has_many :votes, :through => :vote_casts

  class << self
    def party_list
      act = Party.from_vote_name "ACT New Zealand"
      green = Party.from_vote_name "Green Party"
      labour = Party.from_vote_name "New Zealand Labour"
      maori = Party.from_vote_name "Maori Party"
      national = Party.from_vote_name "New Zealand National"
      nz_first = Party.from_vote_name "New Zealand First"
      progressive = Party.from_vote_name "Progressive"
      united_future = Party.from_vote_name "United Future"
      [act, green, labour, maori, national, nz_first, progressive, united_future]
    end

    def party_matrix
      act = from_vote_name "ACT New Zealand"
      green = from_vote_name "Green Party"
      labour = from_vote_name "New Zealand Labour"
      maori = from_vote_name "Māori Party"
      national = from_vote_name "New Zealand National"
      nz_first = from_vote_name "New Zealand First"
      progressive = from_vote_name "Progressive"
      united_future = from_vote_name "United Future"
      independent = from_vote_name "Independent"

      matrix = [
[	[labour , labour, 0, []], 	[labour , national, 0, []], 	[labour , green, 0, []], 	[labour , nz_first, 0, []], 	[labour , maori, 0, []], 	[labour , act, 0, []], 	[labour , united_future, 0, []], 	[labour , progressive, 0, []] 	],
[	[progressive, labour, 0, []], 	[progressive, national, 0, []], 	[progressive, green, 0, []], 	[progressive, nz_first, 0, []], 	[progressive, maori, 0, []], 	[progressive, act, 0, []], 	[progressive, united_future, 0, []], 	[progressive, progressive, 0, []] 	],
[	[nz_first, labour, 0, []], 	[nz_first, national, 0, []], 	[nz_first, green, 0, []], 	[nz_first, nz_first, 0, []], 	[nz_first, maori, 0, []], 	[nz_first, act, 0, []], 	[nz_first, united_future, 0, []], 	[nz_first, progressive, 0, []] 	],
[	[united_future, labour, 0, []], 	[united_future, national, 0, []], 	[united_future, green, 0, []], 	[united_future, nz_first, 0, []], 	[united_future, maori, 0, []], 	[united_future, act, 0, []], 	[united_future, united_future, 0, []], 	[united_future, progressive, 0, []] 	],
[	[green , labour, 0, []], 	[green , national, 0, []], 	[green , green, 0, []], 	[green , nz_first, 0, []], 	[green , maori, 0, []], 	[green , act, 0, []], 	[green , united_future, 0, []], 	[green , progressive, 0, []] 	],
[	[maori , labour, 0, []], 	[maori , national, 0, []], 	[maori , green, 0, []], 	[maori , nz_first, 0, []], 	[maori , maori, 0, []], 	[maori , act, 0, []], 	[maori , united_future, 0, []], 	[maori , progressive, 0, []] 	],
[	[national, labour, 0, []], 	[national, national, 0, []], 	[national, green, 0, []], 	[national, nz_first, 0, []], 	[national, maori, 0, []], 	[national, act, 0, []], 	[national, united_future, 0, []], 	[national, progressive, 0, []] 	],
[	[act , labour, 0, []], 	[act , national, 0, []], 	[act , green, 0, []], 	[act , nz_first, 0, []], 	[act , maori, 0, []], 	[act , act, 0, []], 	[act , united_future, 0, []], 	[act , progressive, 0, []] 	]
      ]
    end

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

  def split_party_votes
    PartyVote.all_unique.select {|p| p.noes_by_party[0].include?(self) && p.ayes_by_party[0].include?(self)}
  end

  def aye_votes_together other_party
    votes_together other_party, :ayes
  end

  def noe_votes_together other_party
    votes_together other_party, :noes
  end

  def votes_together other_party, cast
    third_reading_matrix = Vote.third_reading_matrix cast
    votes_together = nil

    third_reading_matrix.each do |row|
      cell = row.rassoc(self)
      if cell[0] == other_party
        votes_together = cell[3]
        break
      end
    end
    votes_together.sort_by(&:bill_name)
  end

  def url_name
    short.downcase.sub(' ','_')
  end

  def donations_total
    donations.collect(&:amount).sum
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
