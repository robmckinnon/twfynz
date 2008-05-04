class Portfolio < ActiveRecord::Base

  has_many :oral_answers, :as => :about

  def Portfolio::questions_asked_count_by_month name
    if name == 'all'
      counts = Portfolio::questions_asked_count_by_month_for_all
    else
      counts = Portfolio::questions_asked_count_by_month_for name
    end
  end

  def self.find_all_with_debates
    portfolios = find(:all, :include => :oral_answers)
    portfolios.select { |p| p.debate_count > 0 }
  end

  def self.find_all_without_debates
    portfolios = find(:all, :include => :oral_answers)
    portfolios.select {|b| b.debate_count ==  0}
  end

  def full_name
    self.portfolio_name
  end

  def debate_count
    [count_by_about('U'), count_by_about('A'), count_by_about('F')].max
  end

  def unique_oral_answers
    Debate::remove_duplicates(oral_answers)
  end

  def questions_asked
    unique_oral_answers.inject([]) do |list, oral|
      list + oral.contributions.select {|o| o.is_question? }
    end
  end

  def questions_asked_count
    unique_oral_answers.inject(0) do |count, oral|
      sql = %Q[select count(*) from contributions where spoken_in_id = #{oral.id} and (type = 'SubsQuestion' or type = 'SupQuestion')]
      count + Contribution.count_by_sql(sql)
    end
  end

  private

    def Portfolio::questions_asked_count_by_month_for_all
      debates = Debate::remove_duplicates Debate.find_all_by_type_and_about_type('OralAnswer','Portfolio')

      questions_asked = debates.inject([]) do |list, oral|
        list + oral.contributions.select {|o| o.is_question? }
      end
      group_count_by_month questions_asked
    end

    def Portfolio::questions_asked_count_by_month_for name
      portfolio = find_by_url(name, :include => :oral_answers)
      questions_asked = portfolio.questions_asked
      remove_last = !SittingDay::past_last_sitting_date_in_month?
      counts = group_count_by_month questions_asked, remove_last
      if counts.select { |i| i > 0 }.size == 0
        counts = group_count_by_month questions_asked, (Date::today.month == 1)
      end
      counts
    end

    def Portfolio::group_count_by_month questions_asked, remove_last=true
      buckets = {}
      Date::today.downto(Date.parse('2005-11-01')) {|d| buckets[d.to_s[0,7]] = 0 if d.day == 1}
      questions_asked.each {|q| buckets[q.debate.date.to_s[0,7]] += 1}
      buckets = buckets.sort
      buckets.pop if remove_last
      buckets.collect {|a,b| b}
    end

    def count_by_about publication_status
      sql = %Q[select count(*) from debates where about_type = 'Portfolio' and about_id = #{id} and publication_status = '#{publication_status}']
      Debate.count_by_sql(sql)
    end

end
