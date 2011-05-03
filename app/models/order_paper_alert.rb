# require 'twitter'

class OrderPaperAlert < ActiveRecord::Base

  def tweet_alert
    return if in_past?
    alerts = self.class.find_all_by_name_and_alert_date(name, alert_date)
    if alerts.empty?
      Twfynz.twitter_update(tweet_message)
      save!
    end
  end

  def in_past?
    (alert_date < Date.today) || (order_paper_date < Date.today)
  end

  # returns 140 char message
  def tweet_message
    "showing #{name}: #{url}"
  end

end
