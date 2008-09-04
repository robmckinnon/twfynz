class Date

  def utc
    to_time.utc
  end

  def is_sitting_day?
    SittingDay.exists? :date => self
  end

  def has_debates?
    Debate.exists? :date => self
  end

  def has_oral_answers?
    day = SittingDay.find_by_date self
    day.has_oral_answers?
  end

  def has_advance?
    day = SittingDay.find_by_date self
    day.has_advance?
  end

  def has_final?
    day = SittingDay.find_by_date self
    day.has_final?
  end

  def as_date
    text = strftime "%d %B %Y"
    text = text[1..(text.size-1)] if text.size > 0 and text[0..0] == '0'
    text
  end
end
