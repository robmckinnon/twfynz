require 'date'

class SittingDay < ActiveRecord::Base

  def SittingDay::past_last_sitting_date_in_month?
    Date::today >= last_sitting_date_in_month
  end

  def SittingDay::has_parlywords? date
    false
  end

  protected
    def SittingDay::last_sitting_date_in_month
      date = Date::today
      days = SittingDay.find_by_sql("select * from sitting_days where year(date) = '#{date.year}' and month(date) = '#{date.month}'")
      if days.size > 0
        days.sort_by(&:date).last.date
      else
        SittingDay.find(:all).sort_by(&:date).last.date
      end
    end
end


