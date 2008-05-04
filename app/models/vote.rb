class Vote < ActiveRecord::Base

  has_one :contribution

  has_many :ayes, :class_name => 'VoteCast', :conditions => 'cast = "aye"', :order => 'id'
  has_many :noes, :class_name => 'VoteCast', :conditions => 'cast = "noe"', :order => 'id'
  has_many :abstentions, :class_name => 'VoteCast', :conditions => 'cast = "abstention"', :order => 'id'

  has_many :vote_casts, :dependent => :destroy

  validates_presence_of :vote_question
  validates_presence_of :vote_result

  before_validation_on_create :default_vote_tallies

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
    party_and_votes ayes
  end

  def noes_by_party
    party_and_votes noes
  end

  def abstentions_by_party
    party_and_votes abstentions
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

    def cast_count votes
      votes.inject(0) {|count, vote| count += vote.cast_count}
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
      return parties, votes
    end

end
