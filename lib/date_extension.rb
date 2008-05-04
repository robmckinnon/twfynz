class Date

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
end
