class DebateDate

  attr_reader :year, :month, :day, :hash

  MONTHS = ['january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december']
  MONTHS_ABBR = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']

  def initialize params
    @hash = params
    @year = params[:year]
    @month = params[:month]
    @day = params[:day]
  end

  def is_valid_date?
    @year.length == 4 and (!@month or @month.length == 3) and (!@day or @day.length == 2)
  end

  def yyyy_mm_dd
    mm = Debate::MONTHS_LC.index(month) + 1
    mm = (mm < 10) ? "0#{mm}" : mm.to_s
    "#{year}-#{mm}-#{day}"
  end

  def to_hash
    { :year => year, :month => month, :day => day }
  end

  def month
    if @month and @month.length < 3
      Debate.mm_to_mmm @month
    elsif @month and @month.length > 3
      Debate.mm_to_mmm MONTHS.index(@month.downcase)+1
    else
      @month
    end
  end

  def day
    (@day && @day.length == 1) ? "0#{@day}" : @day
  end

  def strftime pattern
    if (pattern == "%d %b %Y" || pattern == "%d %B %Y")
      if @day
        to_date.strftime(pattern)
      elsif @month
        date = to_date.strftime pattern
        date = date.split(' ')
        date[1] + ' ' + date[2]
      else
        @year.to_s
      end
    elsif (@day and pattern == "%A")
      to_date.strftime(pattern)
    else
      ''
    end
  end

  def to_date
    month_number = MONTHS_ABBR.index(month) + 1 if @month

    if @day
      Date.new(@year.to_i, month_number, @day.to_i)
    elsif @month
      Date.new(@year.to_i, month_number, 1)
    else
      Date.new(@year.to_i, 1, 1)
    end
  end
end
