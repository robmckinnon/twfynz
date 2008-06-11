class Member < ActiveRecord::Base

  belongs_to :party
  belongs_to :person, :class_name => 'Mp'

  def maiden_statement_date
    maiden_statement_url ? date_from_url(maiden_statement_url) : nil
  end

  def members_sworn_date
    members_sworn_url ? date_from_url(members_sworn_url) : nil
  end

  def is_active_on date
    if from_date == nil
      false
    elsif to_date
      date >= from_date && date <= to_date
    else
      date >= from_date
    end
  end

  private
  def date_from_url url
    Date.parse url[/\d\d\d\d\/\S\S\S\/\d\d/]
  end
end
