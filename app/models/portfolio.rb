class Portfolio < ActiveRecord::Base

  has_many :ministers, :foreign_key => 'responsible_for_id'
  has_many :oral_answers, :as => :about

  class << self
    
    def create_portfolio name, url, minister
      portfolio = Portfolio.create :portfolio_name => name, :url => url
      minister = Minister.create :title => minister, :responsible_for_id => portfolio.id
      portfolio
    end

    def questions_asked_count_by_month name
      (name == 'all') ? questions_asked_count_by_month_for_all : questions_asked_count_by_month_for(name)
    end

    def find_all_with_debates
      portfolios = find(:all, :include => :oral_answers)
      portfolios.select { |p| p.debate_count > 0 }
    end

    def find_all_without_debates
      portfolios = find(:all, :include => :oral_answers)
      portfolios.select {|b| b.debate_count ==  0}
    end

    def name_to_questions_asked_count
      find(:all).collect do |p|
        [p.full_name, p.questions_asked_count]
      end
    end

    def all_portfolio_names
      @all_portfolio_names = Portfolio.all.collect(&:portfolio_name).sort.collect{|name| name.sub('Maori','Māori')} unless @all_portfolio_names
      @all_portfolio_names
    end
  end

  def full_name
    portfolio_name
  end

  def debate_count
    [count_by_about('U'), count_by_about('A'), count_by_about('F')].max
  end

  def unique_oral_answers
    @unique_oral_answers = Debate::remove_duplicates(oral_answers) unless @unique_oral_answers
    @unique_oral_answers
  end

  def questions_asked
    unique_oral_answers.collect(&:questions).flatten
  end

  def questions_asked_count
    @questions_asked_count = unique_oral_answers.inject(0) do |count, oral|
      sql = %Q[select count(*) from contributions where spoken_in_id = #{oral.id} and (type = 'SubsQuestion' or type = 'SupQuestion')]
      count + Contribution.count_by_sql(sql)
    end unless @questions_asked_count
    @questions_asked_count
  end

  private

    class << self
      def questions_asked_count_by_month_for_all
        debates = Debate::remove_duplicates Debate.find_all_by_type_and_about_type('OralAnswer','Portfolio')

        questions_asked = debates.collect(&:questions).flatten

        group_count_by_month questions_asked
      end

      def questions_asked_count_by_month_for name
        portfolio = find_by_url(name, :include => :oral_answers)
        questions_asked = portfolio.questions_asked
        remove_last = !SittingDay::past_last_sitting_date_in_month?
        counts = group_count_by_month questions_asked, remove_last
        if counts.select { |i| i > 0 }.size == 0
          counts = group_count_by_month questions_asked, (Date::today.month == 1)
        end
        counts
      end

      def group_count_by_month questions_asked, remove_last=true
        buckets = {}
        Date::today.downto(Date.parse('2005-11-01')) {|d| buckets[d.to_s[0,7]] = 0 if d.day == 1}
        questions_asked.each {|q| buckets[q.debate.date.to_s[0,7]] += 1}
        buckets = buckets.sort
        buckets.pop if remove_last
        buckets.collect {|a,b| b}
      end
    end

    def count_by_about publication_status
      sql = %Q[select count(*) from debates where about_type = 'Portfolio' and about_id = #{id} and publication_status = '#{publication_status}']
      Debate.count_by_sql(sql)
    end
end
