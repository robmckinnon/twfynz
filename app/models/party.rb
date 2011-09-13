class Party < ActiveRecord::Base

  acts_as_wikipedia

  has_many :parliament_parties
  has_many :mps, :foreign_key => 'member_of_id'
  has_many :members

  has_many :donations

  has_many :vote_casts
  has_many :votes, :through => :vote_casts, :include => {:contribution => :spoken_in}

  class << self
    def act; @act ||= from_vote_name("ACT New Zealand"); end
    def green; @green ||= from_vote_name("Green Party"); end
    def labour; @labour ||= from_vote_name("New Zealand Labour"); end
    def maori; @maori ||= from_vote_name("Maori Party"); end
    def national; @national ||= from_vote_name("New Zealand National"); end
    def nz_first; @nz_first ||= from_vote_name("New Zealand First"); end
    def progressive; @progressive ||= from_vote_name("Progressive"); end
    def united_future; @united_future ||= from_vote_name("United Future"); end
    def mana; @mana ||= from_vote_name("Mana"); end

    def party_list
      [act, green, labour, maori, national, nz_first, progressive, united_future]
    end

    def party_matrix
      act = Party.act
      green = Party.green
      labour = Party.labour
      maori = Party.maori
      national = Party.national
      nz_first = Party.nz_first
      progressive = Party.progressive
      united_future = Party.united_future
      independent = from_vote_name "Independent"

      matrix = [
[	[labour , labour, 0, {}], 	[labour , national, 0, {}], 	[labour , green, 0, {}], 	[labour , nz_first, 0, {}], 	[labour , maori, 0, {}], 	[labour , act, 0, {}], 	[labour , united_future, 0, {}], 	[labour , progressive, 0, {}] 	],
[	[progressive, labour, 0, {}], 	[progressive, national, 0, {}], 	[progressive, green, 0, {}], 	[progressive, nz_first, 0, {}], 	[progressive, maori, 0, {}], 	[progressive, act, 0, {}], 	[progressive, united_future, 0, {}], 	[progressive, progressive, 0, {}] 	],
[	[nz_first, labour, 0, {}], 	[nz_first, national, 0, {}], 	[nz_first, green, 0, {}], 	[nz_first, nz_first, 0, {}], 	[nz_first, maori, 0, {}], 	[nz_first, act, 0, {}], 	[nz_first, united_future, 0, {}], 	[nz_first, progressive, 0, {}] 	],
[	[united_future, labour, 0, {}], 	[united_future, national, 0, {}], 	[united_future, green, 0, {}], 	[united_future, nz_first, 0, {}], 	[united_future, maori, 0, {}], 	[united_future, act, 0, {}], 	[united_future, united_future, 0, {}], 	[united_future, progressive, 0, {}] 	],
[	[green , labour, 0, {}], 	[green , national, 0, {}], 	[green , green, 0, {}], 	[green , nz_first, 0, {}], 	[green , maori, 0, {}], 	[green , act, 0, {}], 	[green , united_future, 0, {}], 	[green , progressive, 0, {}] 	],
[	[maori , labour, 0, {}], 	[maori , national, 0, {}], 	[maori , green, 0, {}], 	[maori , nz_first, 0, {}], 	[maori , maori, 0, {}], 	[maori , act, 0, {}], 	[maori , united_future, 0, {}], 	[maori , progressive, 0, {}] 	],
[	[national, labour, 0, {}], 	[national, national, 0, {}], 	[national, green, 0, {}], 	[national, nz_first, 0, {}], 	[national, maori, 0, {}], 	[national, act, 0, {}], 	[national, united_future, 0, {}], 	[national, progressive, 0, {}] 	],
[	[act , labour, 0, {}], 	[act , national, 0, {}], 	[act , green, 0, {}], 	[act , nz_first, 0, {}], 	[act , maori, 0, {}], 	[act , act, 0, {}], 	[act , united_future, 0, {}], 	[act , progressive, 0, {}] 	]
      ]
    end

    def from_vote_name name
      party = find_by_vote_name(name)
      party = find_by_short(name) unless party
      party
    end

    def all_size_ordered
      find(:all, :include => :mps).select{|p| p.mps.size > 0}.sort_by {|p| p.mp_count(49) }.reverse
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

  def display_name
    if short == 'Green'
      'The Green Party'
    elsif short == 'Maori Party'
      'The Māori Party'
    else
      short
    end
  end

  def member_count_on_date date
    @member_count_on_date ||= members.select {|m| m.is_active_on(date)}.size
    @member_count_on_date
  end

  def bill_third_reading_and_negatived_votes parliament_number
    third_reading_and_negatived = Vote.third_reading_and_negatived_votes(parliament_number)
    @bill_third_reading_and_negatived_votes ||= Set.new(party_votes(parliament_number)).&(third_reading_and_negatived).to_a
    @bill_third_reading_and_negatived_votes
  end

  def split_bill_third_reading_and_negatived_votes parliament_number
    votes = bill_third_reading_and_negatived_votes(parliament_number)
    votes.select {|p| p.noes_by_party[1].key?(self) && p.ayes_by_party[1].key?(self)}
  end

  def party_votes parliament_number
    @party_votes ||= Vote.remove_duplicates( votes ).select{|v| Parliament.date_within?(parliament_number, v.debate.date)}
    @party_votes
  end

  def split_party_votes parliament_number
    party_votes(parliament_number).select {|p| p.noes_by_party[1].key?(self) && p.ayes_by_party[1].key?(self)}
  end

  def compare_with other, another
    ayes, noes, abstentions = third_reading_ayes_noes_abstentions
    other_ayes, other_noes, other_abstentions = other.third_reading_ayes_noes_abstentions
    another_ayes, another_noes, another_abstentions = another.third_reading_ayes_noes_abstentions

    only_ayes = ayes - other_ayes - another_ayes
    only_noes = noes - other_noes - another_noes
    only_abstentions = abstentions - other_abstentions - another_abstentions

    ayes_with_other = (ayes - only_ayes) - another_ayes
    noes_with_other = (noes - only_noes) - another_noes
    abstentions_with_other = (abstentions - only_abstentions) - another_abstentions

    ayes_with_another = (ayes - only_ayes) - other_ayes
    noes_with_another = (noes - only_noes) - other_noes
    abstentions_with_another = (abstentions - only_abstentions) - other_abstentions

    ayes_with_both = (ayes - only_ayes - ayes_with_other - ayes_with_another)
    noes_with_both = (noes - only_noes - noes_with_other - noes_with_another)
    abstentions_with_both = (abstentions - only_abstentions - abstentions_with_other - abstentions_with_another)

    only = (only_ayes + only_noes + only_abstentions)
    with_other = (ayes_with_other + noes_with_other + abstentions_with_other)
    with_another = (ayes_with_another + noes_with_another + abstentions_with_another)
    with_both = (ayes_with_both + noes_with_both + abstentions_with_both)
    return [only, with_other, with_another, with_both]
  end

  def in_parliament number
    parliament_parties.select {|p| p.parliament_id == number}.first
  end

  def third_reading_ayes_noes_abstentions
    votes = PartyVote.third_reading_votes
    ayes = votes.select        {|p| p.ayes_by_party[0].include?(self)}
    noes = votes.select        {|p| p.noes_by_party[0].include?(self)}
    abstentions = votes.select {|p| p.abstentions_by_party[0].include?(self)}
    return [ayes, noes, abstentions]
  end

  def aye_votes_together other_party
    votes_together other_party, :ayes
  end

  def noe_votes_together other_party
    votes_together other_party, :noes
  end

  def votes_together other_party, cast
    third_reading_matrix = Vote.third_reading_matrix(cast)
    votes_together = nil

    third_reading_matrix.each do |row|
      cell = row.rassoc(self)
      if cell[0] == other_party
        votes_together = cell[3]
        break
      end
    end
    votes_together.keys.sort_by(&:bill_name)
  end

  def votes_comparison other_party, parliament_number
    votes = Vote.third_reading_and_negatived_votes(parliament_number)

    ayes_ayes = []
    noes_noes = []
    abstentions_abstentions = []
    novote_novote = []
    bothways_bothways = []

    ayes_noes = []
    noes_ayes = []

    ayes_abstentions = []
    noes_abstentions = []

    ayes_novote = []
    noes_novote = []

    ayes_bothways = []
    noes_bothways = []

    abstentions_ayes = []
    abstentions_noes = []
    abstentions_novote = []
    abstentions_bothways = []

    novote_ayes = []
    novote_noes = []
    novote_abstentions = []
    novote_bothways = []

    bothways_ayes = []
    bothways_noes = []
    bothways_abstentions = []
    bothways_novote = []

    votes.each do |vote|
      ayes = vote.ayes_cast_by_party
      noes = vote.noes_cast_by_party
      abstentions = vote.abstentions_cast_by_party

      if (ayes.key?(self) && noes.key?(self)) && (ayes.key?(other_party) && noes.key?(other_party))
        bothways_bothways << vote
      elsif (ayes.key?(self) && noes.key?(self)) && ayes.key?(other_party)
        bothways_ayes << vote
      elsif ayes.key?(self) && (ayes.key?(other_party) && noes.key?(other_party))
        ayes_bothways << vote
      elsif (ayes.key?(self) && noes.key?(self)) && noes.key?(other_party)
        bothways_noes << vote
      elsif noes.key?(self) && (ayes.key?(other_party) && noes.key?(other_party))
        noes_bothways << vote
      elsif ayes.key?(self) && ayes.key?(other_party)
        ayes_ayes << vote
      elsif noes.key?(self) && noes.key?(other_party)
        noes_noes << vote
      elsif ayes.key?(self) && noes.key?(other_party)
        ayes_noes << vote
      elsif noes.key?(self) && ayes.key?(other_party)
        noes_ayes << vote
      elsif noes.key?(self) && noes.key?(other_party)
        noes_noes << vote
      elsif (ayes.key?(self) && noes.key?(self)) && abstentions.key?(other_party)
        bothways_abstentions << vote
      elsif abstentions.key?(self) && (ayes.key?(other_party) && noes.key?(other_party))
        abstentions_bothways << vote
      elsif abstentions.key?(self) && abstentions.key?(other_party)
        abstentions_abstentions << vote
      elsif ayes.key?(self) && abstentions.key?(other_party)
        ayes_abstentions << vote
      elsif noes.key?(self) && abstentions.key?(other_party)
        noes_abstentions << vote
      elsif abstentions.key?(self) && ayes.key?(other_party)
        abstentions_ayes << vote
      elsif abstentions.key?(self) && noes.key?(other_party)
        abstentions_noes << vote
      elsif !ayes.key?(self) && !noes.key?(self) && !abstentions.key?(self)
        if (ayes.key?(other_party) && noes.key?(other_party))
          novote_bothways << vote
        elsif ayes.key?(other_party)
          novote_ayes << vote
        elsif noes.key?(other_party)
          novote_noes << vote
        elsif abstentions.key?(other_party)
          novote_abstentions << vote
        else
          novote_novote << vote
        end
      elsif !ayes.key?(other_party) && !noes.key?(other_party) && !abstentions.key?(other_party)
        if (ayes.key?(self) && noes.key?(self))
          bothways_novote << vote
        elsif ayes.key?(self)
          ayes_novote << vote
        elsif noes.key?(self)
          noes_novote << vote
        elsif abstentions.key?(self)
          abstentions_novote << vote
        else
          raise 'unexpected ' + vote.inspect
        end
      end
    end
    return [ayes_ayes.sort_by(&:bill_name), noes_noes.sort_by(&:bill_name), ayes_noes.sort_by(&:bill_name), noes_ayes.sort_by(&:bill_name),
    abstentions_abstentions.sort_by(&:bill_name), ayes_abstentions.sort_by(&:bill_name), noes_abstentions.sort_by(&:bill_name),
    abstentions_ayes.sort_by(&:bill_name), abstentions_noes.sort_by(&:bill_name),

    novote_novote.sort_by(&:bill_name),
    ayes_novote.sort_by(&:bill_name),
    noes_novote.sort_by(&:bill_name),
    abstentions_novote.sort_by(&:bill_name),
    novote_ayes.sort_by(&:bill_name),
    novote_noes.sort_by(&:bill_name),
    novote_abstentions.sort_by(&:bill_name),

    bothways_bothways.sort_by(&:bill_name),
    ayes_bothways.sort_by(&:bill_name),
    noes_bothways.sort_by(&:bill_name),
    abstentions_bothways.sort_by(&:bill_name),
    novote_bothways.sort_by(&:bill_name),
    bothways_ayes.sort_by(&:bill_name),
    bothways_noes.sort_by(&:bill_name),
    bothways_abstentions.sort_by(&:bill_name),
    bothways_novote.sort_by(&:bill_name)
    ]
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

  def mp_count parliament_id=49
    @mp_count_hash ||= {}
    unless @mp_count_hash[parliament_id]
      count = members.select { |m| m.in_parliament?(parliament_id) && (parliament_id < 49 || m.is_active_on(Date.today) ) }.size
      @mp_count_hash[parliament_id] = count
    end
    @mp_count_hash[parliament_id]
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
