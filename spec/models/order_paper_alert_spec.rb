require File.dirname(__FILE__) + '/../spec_helper'

describe OrderPaperAlert do
  before do
    alert_date = Date.new(2008,7,18)
    order_paper_date = Date.new(2008,7,22)
    @name = 'Provisional Order Paper for Tuesday, 22 July 2008'
    @url = 'http://www.parliament.nz/en-NZ/?document=00HOHOrderPaper1'
    @alert = OrderPaperAlert.new(@name, order_paper_date, @url, alert_date)
  end

  describe "when asked for tweet_message" do
    it 'should create message containing name and url' do
      @alert.tweet_message.should == "showing #{@name}: #{@url}"
    end

    it 'should create message of less than or equal to 140 characters' do
      @alert.tweet_message.size.should <= 140
    end
  end

  describe "when asked to send twitter alert" do
    it 'should send an update via twitter' do
      tweet_message = 'tweet_message'
      @alert.should_receive(:tweet_message).and_return tweet_message
      Twfynz.should_receive(:twitter_update).with(tweet_message)
      @alert.tweet_alert
    end
  end
end
