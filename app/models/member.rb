class Member < ActiveRecord::Base

  belongs_to :parliament
  belongs_to :party
  belongs_to :person, :class_name => 'Mp'
  belongs_to :replaced_by, :class_name => 'Mp'

  def maiden_statement_date
    maiden_statement_url ? date_from_url(maiden_statement_url) : nil
  end

  def members_sworn_date
    members_sworn_url ? date_from_url(members_sworn_url) : nil
  end

  def resignation_date
    resignation_url ? date_from_url(resignation_url) : nil
  end

  def valedictory_statement_date
    valedictory_statement_url ? date_from_url(valedictory_statement_url) : nil
  end

  def in_parliament? parliament_id
    if parliament_id != self.parliament_id
      false
    elsif Parliament.dissolution_date(parliament_id)
      to_date >= Parliament.dissolution_date(parliament_id)
    else
      true
    end
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
