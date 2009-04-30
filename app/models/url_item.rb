class UrlItem

  attr_reader :title, :date

  def initialize item
    @item = item
    @path = item.path
    @title = title_from_path item.path
  end

  def unique_pageviews
    @item.unique_pageviews
  end

  def url
    @item.url
  end

  def page_title
    title
  end

  def weighted_score
    if date
      months = ( date.to_time - Time.now.years_ago(1) ) / ( 60 * 60 * 24.0 ) / (365.25/12)
      if months < 0
        0
      else
        [0, (months/12.0) * @item.unique_pageviews.to_i ].max
      end
    else
      @item.unique_pageviews.to_i
    end
  end

  private

    def title_from_path path
      case path.gsub('/',' ')
        when /^ debates (\d\d\d\d) (\S\S\S) (\d\d)$/
          date = DebateDate.new({:year=>$1,:month=>$2,:day=>$3})
          @date = date.to_date
          debates = Debate.find_by_date(date.year, date.month, date.day)
          if debates.first.is_a? OralAnswers
            "Questions for Oral Answer, #{date.to_date.as_date}"
          else
            "Parlimentary Debates, #{date.to_date.as_date}"
          end
        when /^ (bills|portfolios|committees) (\S+)$/
          about = $1.singularize.titleize.constantize.find_by_url($2)
          about ? about.send("#{$1.singularize}_name") : path
        when /^ bills (\S+) submissions$/
          bill = Bill.find_by_url($1)
          "Submissions on #{bill.bill_name}"
        when /^ (bills|portfolios|committees) (\S+) (\d\d\d\d) (\S\S\S) (\d\d) (\S+)$/
          date = DebateDate.new({:year=>$3,:month=>$4,:day=>$5})
          @date = date.to_date
          debate = Debate.find_by_about_on_date_with_slug($1.singularize.titleize.constantize, $2, date, $6)
          if debate
            ($1 == 'bills') ? "#{debate.parent_name}, #{debate.name}" : debate.name
          else
            path
          end
        when /^ (\S+) (\d\d\d\d) (\S\S\S) (\d\d) (\S+)$/
          date = DebateDate.new({:year=>$2,:month=>$3,:day=>$4})
          @date = date.to_date
          debate = Debate.find_by_url_category_and_url_slug(date, $1, $5)
          debate.parent_name ? "#{debate.parent_name}, #{debate.name}" : debate.name
        else
          path
      end
    end

end
