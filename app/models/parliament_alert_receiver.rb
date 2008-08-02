require 'hpricot'

class ParliamentAlertReceiver < ActionMailer::Base

  def receive(email)
    logger.info "receiving: #{email.subject}"

    case email.subject
      when /Order Paper/
        html = (email.parts.first.content_type == 'text/html') ? email.parts.first : email.parts.last
        doc = Hpricot "<wrapper>#{html}</wrapper>"
        (doc/'li').each do |element|
          alert_date = Date.parse(element.at('text()').to_s[/\d\d\/...\/\d\d\d\d/])
          name = element.at('a').inner_text
          order_paper_date = Date.parse(name.to_s[/\d\d\s[^\s]+\s\d\d\d\d/])
          url = element.at('a')['href'].to_s
          logger.info "OrderPaperAlert: #{name}"
          alert = OrderPaperAlert.new(:name => name, :order_paper_date => order_paper_date, :url => url, :alert_date => alert_date)
          alert.tweet_alert
        end
    end
  end

end
