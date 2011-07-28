class Vote < ActiveRecord::Base

  has_one :contribution

  has_many :ayes, :class_name => 'VoteCast', :conditions => 'cast = "aye"', :order => 'id'
  has_many :noes, :class_name => 'VoteCast', :conditions => 'cast = "noe"', :order => 'id'
  has_many :abstentions, :class_name => 'VoteCast', :conditions => 'cast = "abstention"', :order => 'id'

  has_many :vote_casts, :dependent => :destroy

  validates_presence_of :vote_question
  validates_presence_of :vote_result

  before_validation :default_vote_tallies

  class << self
    def value_for_votes votes_cast
      if votes_cast && votes_cast.size == 1
        case votes_cast.first.cast
          when 'aye'
            '1'
          when 'noe'
            '-1'
          else
            '0'
        end
      elsif votes_cast && votes_cast.size > 1
        total = votes_cast.size.to_f
        ayes = votes_cast.select{|v| v.cast == 'aye'}.size
        noes = votes_cast.select{|v| v.cast == 'noe'}.size
        value = (((ayes - noes) / total) * 100).to_i / 100.to_f
        value.to_s
      else
        '0'
      end
    end

    def vote_vectors parliament_number, to_string=true
      parties = Party.party_list
      votes = third_reading_and_negatived_votes(parliament_number)
      vectors = []
      parties.each do |party|
        if parliament_number.to_i == 49 && party == Party.nz_first
          # ignore
        else
          values = [party.short]
          votes.each do |vote|
            x, by_party = vote.votes_by_party
            votes_cast = by_party[party]
            values << value_for_votes(votes_cast)
          end
          vectors << (to_string ? values.join(",") : values)
        end
      end
      vectors
    end

    def voted_same_way(party, other_party, vote_parties)
      vote_parties.key?(party) && vote_parties.key?(other_party)
    end

    def add_to_matrix matrix, votes, cast
      cell_hash = {}

      matrix.each do |row|
        row.each do |cell|
          unless cell.empty?
            party = cell[0]
            other_party = cell[1]

            if party == other_party
              # ignore as not a comparison
            else
              if cell_hash[[other_party, party]]
                # ignore as we have data in diagonal opposite cell
              else
                cell_hash[[party, other_party]] = cell
                votes.each do |vote|
                  parties_cast = {}
                  vote.send(cast).each do |vote_cast|
                    parties_cast[vote_cast.party] = vote_cast.cast_count.to_f / vote_cast.party.member_count_on_date(vote_cast.date)
                  end
                  if voted_same_way(party, other_party, parties_cast)
                    proportion_of_party       = parties_cast[party]
                    proportion_of_other_party = parties_cast[other_party]
                    went_both_ways = vote.noes_by_party[1].key?(party) && vote.ayes_by_party[1].key?(party)
                    other_went_both_ways = vote.noes_by_party[1].key?(other_party) && vote.ayes_by_party[1].key?(other_party)
                    if went_both_ways || other_went_both_ways
                    else
                      cell[2] += 1 # [proportion_of_party, proportion_of_other_party].min
                    end
                    # logger.info vote.debate.parent.name + ' ' + party.short + '(' + proportion_of_party.to_s + ') ' + other_party.short + '(' + proportion_of_other_party.to_s + ') ' + ' ' + cell[2].to_s
                    cell[3][vote] = true
                  end
                end
              end
            end
          end
        end
      end
    end

    def full_matrix matrix
      cell_hash = {}

      matrix.each do |row|
        row.each do |cell|
          unless cell.empty?
            party = cell[0]
            other_party = cell[1]

            if party != other_party && (diagonal_opposite = cell_hash[[other_party, party]])
              cell[2] = diagonal_opposite[2]
              cell[3] = diagonal_opposite[3]
            else
              cell_hash[[party, other_party]] = cell
            end
          end
        end
      end
    end

    def third_reading_matrix parliament_number, cast=nil
      votes = third_reading_and_negatived_votes parliament_number
      matrix = Party.party_matrix
      add_to_matrix matrix, votes, :ayes_cast if !cast || cast == :ayes
      add_to_matrix matrix, votes, :noes_cast if !cast || cast == :noes
      add_to_matrix matrix, votes, :abstentions_cast if !cast || cast == :abstentions
      full_matrix matrix
      count = votes.size.to_f
      matrix.each do |row|
        row.each do |cell|
          unless cell.empty?
            # if cell[0] == cell[1]
              # party = cell[0]
              # split_votes = party.split_bill_third_reading_and_negatived_votes
              # cell[2] = cell[2] - split_votes.size
            # end
            cell[2] = (cell[2] / count) * 100
          end
        end
      end

      matrix
    end

    def third_reading_and_negatived_votes parliament_number
      # @third_reading_and_negatived_votes ||= {}
      # @third_reading_and_negatived_votes[parliament_number] ||= third_reading_votes(parliament_number) + negatived_party_votes(parliament_number)
      # @third_reading_and_negatived_votes[parliament_number]
      third_reading_votes(parliament_number) + negatived_party_votes(parliament_number)
    end

    def negatived_party_votes parliament_number
      negatived_bills = Bill.find_all_negatived
      last_debate_votes = negatived_bills.collect{|b| b.debates.sort_by(&:date).last.votes.last}.compact
      last_debate_votes.select{|v| v.type == 'PartyVote' && Parliament.date_within?(parliament_number, v.debate.date) }
    end

    def third_reading_votes parliament_number
      votes = find(:all, :conditions => 'vote_question like "%third%"', :include => [{:vote_casts => :party}, {:contribution => :spoken_in}])
      votes = votes.select {|x| x.contribution}
      remove_duplicates(votes)
      votes.select{|v| Parliament.date_within?(parliament_number, v.debate.date)}
    end

    def all_unique parliament_number
      votes = find(:all, :include => {:contribution => :spoken_in})
      votes = votes.select{|v| Parliament.date_within?(parliament_number, v.debate.date)}
      remove_duplicates(votes)
    end

    def remove_duplicates votes
      debates = votes.collect(&:debate)
      debates = Debate::remove_duplicates(debates)
      debate_ids = {}
      debates.each {|d| debate_ids[d.id] = true}
      votes.delete_if {|v| (v.debate.publication_status != 'F') && !debate_ids[v.debate.id] }
      votes
    end
  end

  def is_third_reading_vote?
    vote_question && vote_question[/third/] ? true : false
  end

  def debate
    contribution.debate
  end

  def bill
    contribution.bill
  end

  def vote_bill
    if vote_question[/That the bill be now read a \w+ time/]
      bill
    else
      Bill.from_name_and_date bill_name, contribution.date
    end
  end

  def bill_name
    if vote_question[/That the (.+) be now read a \w+ time,? and the/]
      $1
    elsif vote_question[/and the (Imprest Supply .+) be (now )?read a (.+) time/]
      $1
    elsif vote_question[/That the (.+) be now read a (.+) time/] && !$1.include?('Bill, ') && !$1.include?('Bill and')
      $1
    else
      bill ? bill.bill_name : ('no bill for: ' + debate.date.to_s + ' ' + bill_names)
    end
  end

  def bill_names
    debate.debate_topics.collect(&:bill_name).join(', ')
  end

  def reason
    %Q[A #{self.class.to_s.sub('Vote','').downcase} vote was called for on the question, ]
  end

  def question
    %Q[#{vote_question.gsub('&quote;', '"')}]
  end

  def result
    result = vote_result.gsub('&quote;', '"')
    if (result.include? 'Motion agreed to.')
      result = 'Motion agreed: <br />' + motion.gsub('<p>','').gsub('</p>', ' ').gsub('<i>','').gsub('</i>','').sub('I move,','')
    elsif (result.include? 'Motion not agreed to.')
      result = 'Motion not agreed: <br />' + motion.sub('I move,','')
    end
    result
  end

  def motion
    if question == 'That the motion be agreed to.'
      contribution.previous_in_debate.text
    else
      question
    end
  end

  def amendment
    if question == 'That the amendment be agreed to.'
      contribution.previous_in_debate.text
    else
      question
    end
  end

  def votes_by_party
    party_and_votes vote_casts
  end

  def ayes_by_party
    party_and_votes ayes_cast
  end

  def noes_by_party
    party_and_votes noes_cast
  end

  def abstentions_by_party
    party_and_votes abstentions_cast
  end

  def ayes?
    ayes.size > 0
  end

  def noes?
    noes.size > 0
  end

  def abstentions?
    abstentions.size > 0
  end

  def ayes_cast_by_party
    ayes_cast.group_by {|v| v.party}.to_hash
  end

  def noes_cast_by_party
    noes_cast.group_by {|v| v.party}.to_hash
  end

  def abstentions_cast_by_party
    abstentions_cast.group_by {|v| v.party}.to_hash
  end

  def ayes_cast
    vote_casts.select {|c| c.cast == "aye"}
  end

  def noes_cast
    vote_casts.select {|c| c.cast == "noe"}
  end

  def abstentions_cast
    vote_casts.select {|c| c.cast == "abstention"}
  end

  def passed_third_reading?
    vote_question.include?('third') && ayes_have_it?
  end

  def ayes_have_it?
    ayes_cast_count > noes_cast_count
  end

  def ayes_cast_count
    cast_count ayes_cast
  end

  def noes_cast_count
    cast_count noes_cast
  end

  def abstentions_cast_count
    cast_count abstentions_cast
  end

  def votes_count
    cast_count vote_casts
  end

  def ayes_count
    cast_count ayes
  end

  def noes_count
    cast_count noes
  end

  def abstentions_count
    cast_count abstentions
  end

  def direction name='Green'
    the_party = Party.find_by_short name

    counts = [[:ayes,ayes_count],[:noes,noes_count],[:abstentions,abstentions_count]]
    counts.sort! { |a,b| b[1] <=> a[1] }
    direction = counts.first[0]

    parties, votes = send((direction.to_s + '_by_party').to_sym)
    the_vote = votes[the_party]

    new_counts = { :ayes => ayes_count, :noes => noes_count, :abstentions => abstentions_count }
    if the_vote
      cast_count = the_vote[0].cast_count
      new_counts[direction] -= cast_count
      new_counts[direction == :ayes ? :noes : :noes] += cast_count
      new_counts = new_counts.to_a.sort { |a, b| b[1] <=> a[1] }
      name + ' voted with ' + direction.to_s + counts.assoc(direction)[1].to_s + ' majority; otherwise ' + new_counts.first[0].to_s + new_counts.assoc(direction)[1].to_s
    else
      parties, votes = abstentions_by_party
      the_vote = votes[the_party]
      if the_vote
        cast_count = the_vote[0].cast_count
        name + ' abstained from voting'
      else
        name + ' voted against majority'
      end
    end
  end

  private

    def default_vote_tallies
      self.ayes_tally = 0 if self.ayes_tally.nil?
      self.noes_tally = 0 if self.noes_tally.nil?
      self.abstentions_tally = 0 if self.abstentions_tally.nil?
    end

    def cast_count vote_casts
      vote_casts.inject(0) {|count, vote| count += vote.cast_count}
    end

    def party_and_votes votes
      votes = votes.group_by {|v| v.party}
      parties = votes.keys.sort do |x, y|
        if (x.vote_name == 'Independent' and y.vote_name == 'Independent')
          0
        elsif x.vote_name == 'Independent'
          +1
        elsif y.vote_name == 'Independent'
          -1
        else
          cast_count(votes[y]) <=> cast_count(votes[x])
        end
      end
      return parties, votes.to_hash
    end

end
