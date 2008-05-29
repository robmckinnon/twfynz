class Mp < ActiveRecord::Base

  validates_presence_of :last
  validates_presence_of :first
  validates_presence_of :elected
  validates_presence_of :id_name
  validates_presence_of :img

  belongs_to :party, :foreign_key => 'member_of_id'

  has_many :pecuniary_interests
  has_many :bills, :foreign_key => 'member_in_charge_id'
  has_many :contributions, :foreign_key => 'spoken_by_id'

  TITLES = ['Dr the Hon', 'Rt Hon', 'Hon Dr', 'Hon', 'Dr', 'Sir']

  # before_save :set_wikipedia

  def anchor
    party.short == 'Independent' ? nil : party.short.downcase.gsub(' ','_')
  end

  def set_wikipedia
    self.wikipedia_url = "http://en.wikipedia.org/wiki/#{first}_#{last.downcase.titleize}" unless !self.wikipedia_url.blank?
  end

  def self.from_vote_name name
    name = 'Roy E' if name == 'E Roy'
    name_downcase = name.downcase.strip.gsub('’',"'")
    mps = Mp.find(:all)
    matching = mps.select {|mp| mp.last.downcase == name_downcase }
    if matching.size == 0
      matching = mps.select {|mp| (mp.last.downcase + ' ' + mp.first.downcase[0..0]) == name_downcase}
      if matching.size == 0
        matching = mps.select {|mp| (mp.last.downcase + mp.first.downcase[0..0]) == name_downcase}
      end
    end

    if matching.size == 1
      return matching[0]
    elsif matching.empty?
      raise 'no matching MP for vote name: ' + name
    else
      matching = matching.select {|mp| !mp.former}
      if matching.size == 1
        return matching[0]
      else
        raise 'more than one matching MP for vote name: ' + name
      end
    end
  end

  def self.from_name speaker_name
    mp = nil
    unless speaker_name.blank?
      name = String.new speaker_name
      TITLES.each {|t| name.gsub!(t+' ', '')}
      name.strip!
      speaker = name.split('(')[0].downcase.strip.gsub('’',"'")

      unless speaker.include? 'speaker' or speaker.include? 'member' or speaker.include? 'chairperson'
        Mp.find(:all).each do |m|
          if ((m.downcase_name == speaker) or
              (m.alt_downcase_name and m.alt_downcase_name == speaker) or
              (m.downcase_name.gsub(' ','') == speaker) or
              (m.alt_downcase_name and m.alt_downcase_name.sub(' ','') == speaker))
            mp = m
            break
          end
        end
      end

      if (speaker == 'madam speaker' or speaker == 'madam speaker-elect' or speaker == 'madsam speaker')
        mp = Mp.find_by_first_and_last 'Margaret','Wilson'

      elsif speaker == 'prime minister'
        mp = Mp.find_by_first_and_last 'Helen','Clark'

      elsif speaker == 'deputy prime minister'
        mp = Mp.find_by_first_and_last 'Michael','Cullen'

      elsif speaker == 'mr deputy speaker'
        mp = Mp.find_by_first_and_last 'Clem','Simich'

      elsif ((speaker == 'the assistant speaker' or
          speaker == 'the chairperson' or
          speaker == 'the temporary speaker') and name.include?('('))
        mp = Mp.from_name name.split('(')[1].chop.strip
      end
    end
    mp
  end

  def self.all_by_last
    @mps = Mp.find(:all, :order => "last", :include => :party)
  end

  def self.all_by_first
    @mps = Mp.find(:all, :order => "first", :include => :party)
  end

  def self.all_by_electorate
    mps = Mp.find(:all, :order => "electorate", :include => :party)
    list_mps = mps.select {|mp| mp.electorate == 'List'}.sort{|a,b| a.last <=> b.last}

    mps = mps.select {|mp| mp.electorate? } - list_mps
    @mps = (mps + list_mps)
  end

  def self.all_by_party
    mps = Mp.find(:all, :include => :party)
    mps = mps.select {|m| m.party}
    mps_by_party = mps.group_by {|m| m.party.short }
    parties = mps_by_party.keys.sort

    mps = []
    parties.each do |party|
      mps << mps_by_party[party]
    end
    @mps = mps.flatten
    # @mps = Mp.find(:all, :order => "member_of_id")
  end

  def full_name
    @full_name = first + ' ' + last unless @full_name
    @full_name
  end

  def downcase_name
    @downcase_name = (first.downcase + ' ' + last.downcase) unless @downcase_name
    @downcase_name
  end

  def alt_downcase_name
    if alt
      @alt_downcase_name = (alt.downcase + ' ' + last.downcase) unless @alt_downcase_name
    end
    @alt_downcase_name
  end

  def is_former?
    if former.is_a? String
      former.to_s == "\001"
    else
      former
    end
  end

  def bills_in_charge_of
    bills.select { |b| b.current? }
  end

  def recent_contributions
    Contribution::recent_contributions contributions, id, Mp
  end

  def list_mp?
    return electorate == 'List'
  end

  def pecuniary_interests_by_category
    interests = pecuniary_interests

    categories = {}
    interests.each do |interest|
      categories[interest.pecuniary_category] = [] unless categories[interest.pecuniary_category]
      categories[interest.pecuniary_category] << interest
    end
    categories.sort {|a,b| a[0].id <=> b[0].id}
  end

  def portfolios_asked_about
    portfolios = question_debates.select {|d| d.about_type == 'Portfolio' }.group_by {|d| d.about}
    portfolios = most_frequent portfolios
    portfolios.sort! { |a,b| b[1].size <=> a[1].size }
    # portfolios.collect {|p| p[0]}
    portfolios
  end

  def portfolios_answered_about
    portfolios = answer_debates.select {|d| d.about_type == 'Portfolio' }.group_by {|d| d.about}
    portfolios = most_frequent portfolios
    portfolios.sort! { |a,b| b[1].size <=> a[1].size }
    # portfolios.collect {|p| p[0]}
    portfolios
  end

  def subjects_asked_about
    subjects = question_debates.group_by {|d| d.name.split('—').first }
    subjects = most_frequent subjects
    subjects.sort! { |a,b| b[1].last.date <=> a[1].last.date }
    # subjects.collect {|s| "#{s[0]} (#{s[1]})"}
    # subjects.collect {|s| s[0]}
    subjects
  end

  def subjects_answered_about
    subjects = answer_debates.group_by {|d| d.name.split('—').first }
    subjects = most_frequent subjects
    subjects.sort! { |a,b| b[1].last.date <=> a[1].last.date }
    # subjects.collect {|s| s[0]}
    subjects
  end

  def question_debates
    @question_debates = oral_answer_debates SubsQuestion, SupQuestion unless @question_debates
    @question_debates
  end

  def answer_debates
    @answer_debates = oral_answer_debates SubsAnswer, SupAnswer unless @answer_debates
    @answer_debates
  end

  private

    def oral_answer_debates type, supplementary_type
      oral_answers = contributions.select {|o| o.debate.class == OralAnswer}
      debates = oral_answers.select {|o| o.class == type}.collect {|o| o.debate}.uniq

      supplementary_debates = oral_answers.select {|o| o.class == supplementary_type}.collect {|o| o.debate}.uniq

      supplementary_debates.delete_if {|d| debates.include? d}
      debates = Debate::remove_duplicates debates
      supplementary_debates = Debate::remove_duplicates supplementary_debates

      debates = (debates << supplementary_debates).flatten
      debates
    end

    def most_frequent subjects
      name_to_count = {}
      subjects.keys.each do |name|
        x = subjects[name].size
        name_to_count[name] = x
      end
      name_and_count = name_to_count.sort {|a,b| b[1]<=>a[1]}
      if name_and_count.size > 5
        frequency = name_and_count[4][1]
        index = 4
        while index.next < name_and_count.size and name_and_count[index.next][1] == frequency
          index += 1
        end
        name_and_count = name_and_count[0..index]
      end

      if name_and_count.size > 8
        frequency = name_and_count.last[1]
        index = name_and_count.size-1
        while index-1 > 0 and name_and_count[index-1][1] == frequency
          index -= 1
        end
        name_and_count = name_and_count[0..index-1]
      end

      frequent = subjects.select {|name, debates| name_and_count.assoc(name)}
      frequent.each do |name_and_debates|
        name_and_debates[1].sort! {|a,b| a.date <=> b.date}
      end

      frequent
    end
end
