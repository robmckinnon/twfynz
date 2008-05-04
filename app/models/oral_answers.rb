class OralAnswers < Debate

  has_many :oral_answers, :class_name => 'OralAnswer',
           :order => 'debate_index',
           :foreign_key => 'debate_id'

  def self.find_by_date_answer_no date, oral_answer_no
    Debate.with_scope(:find => {:conditions => "about_type = '"+type+"'"}) do
      Debate.find :all,
          :conditions => ["o.url = ?", name],
          :joins => "AS d INNER JOIN "+type.downcase+"s AS o ON d.about_id = o.id"
    end
  end

  def self.recent_by_type publication_status
    find(:all,
        :conditions => ["debates.`publication_status` = '" + publication_status.to_s + "'"],
        :order => "debates.`date` DESC",
        :limit => 6,
        :include => :oral_answers).group_by {|d| d.date}
  end

  def self.recent
    uncorrected = OralAnswers.recent_by_type(:U)
    advance = OralAnswers.recent_by_type(:A)
    final = OralAnswers.recent_by_type(:F)

    answers = Debate::remove_duplicates_using uncorrected, advance, final
    by_date = answers.group_by{|a| a.date }

    answers = []
    by_date.keys.sort.reverse.each_with_index do |date, i|
      answers << by_date[date] if i < 3
    end
    answers.flatten
  end

  def self.recent_grouped
    recents = self.recent.collect { |o| o.oral_answers }.flatten.sort_by{|o| o.about ? o.about.full_name : 'no_about' }
    recents.in_groups_by { |o| o.about ? o.about.full_name : 'no_about' }
  end

  def heading_level
    4
  end

  def sub_debates
    oral_answers
  end

  def category
    ''
  end

  def add_oral_answer answer
    answer.valid?
    answer.debate = self
    self.oral_answers << answer

    about_index = self.oral_answers.select {|o| o.about_type == answer.about_type && o.about_id == answer.about_id }.size
    answer.about_index = about_index
  end

  ##
  # index of next debate
  def next_index
    if oral_answers.size == 1
      index.next
    else
      index.next
    end
  end

end
