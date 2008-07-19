require 'twitter'

class OrderPaperAlert

  def initialize name, order_paper_date, url, alert_date
    @name, @order_paper_date, @url, @alert_date = name, order_paper_date, url, alert_date
  end

  def tweet_alert
    Twfynz.twitter_update(tweet_message)
  end

  # returns 140 char message
  def tweet_message
    "showing #{@name}: #{@url}"
  end

end
