class Member < ActiveRecord::Base

  belongs_to :party
  belongs_to :person, :class_name => 'Mp'

  def is_active_on date
    if from_date == nil
      false
    elsif to_date
      date >= from_date && date <= to_date
    else
      date >= from_date
    end
  end
end
