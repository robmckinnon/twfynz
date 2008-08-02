require File.dirname(__FILE__) + '/../spec_helper'

describe OrderPaperAlert do
  before do
    @alert_date = Date.new(2008,7,18)
    order_paper_date = Date.new(2008,7,22)
    @name = 'Provisional Order Paper for Tuesday, 22 July 2008'
    @url = 'http://www.parliament.nz/en-NZ/?document=00HOHOrderPaper1'
    @alert = OrderPaperAlert.new(:name => @name, :order_paper_date => order_paper_date, :url => @url, :alert_date => @alert_date)
  end

  describe "when asked for tweet_message" do
    it 'should create message containing name and url' do
      @alert.tweet_message.should == "showing #{@name}: #{@url}"
    end

    it 'should create message of less than or equal to 140 characters' do
      @alert.tweet_message.size.should <= 140
    end
  end

  describe 'when asked if in past' do
    it 'should return true if alert date in past' do
      @alert.stub!(:alert_date).and_return(Date.today - 1)
      @alert.stub!(:order_paper_date).and_return Date.today
      @alert.in_past?.should be_true
    end
    it 'should return true if order paper date in past' do
      @alert.stub!(:alert_date).and_return Date.today
      @alert.stub!(:order_paper_date).and_return(Date.today - 1)
      @alert.in_past?.should be_true
    end
    it 'should return false if order paper date and alert date are today' do
      @alert.stub!(:alert_date).and_return Date.today
      @alert.stub!(:order_paper_date).and_return Date.today
      @alert.in_past?.should be_false
    end
    it 'should return false if order paper date and alert date in future' do
      @alert.stub!(:alert_date).and_return(Date.today + 1)
      @alert.stub!(:order_paper_date).and_return(Date.today + 1)
      @alert.in_past?.should be_false
    end
  end

  describe "when asked to send twitter alert" do
    describe "for the first time on an alert date" do
      describe "and not in the past" do
        it 'should send an update via twitter and save alert' do
          OrderPaperAlert.should_receive(:find_all_by_name_and_alert_date).with(@name, @alert_date).and_return []
          tweet_message = 'tweet_message'
          @alert.stub!(:in_past?).and_return false
          @alert.should_receive(:tweet_message).and_return tweet_message
          Twfynz.should_receive(:twitter_update).with(tweet_message)
          @alert.should_receive(:save!)
          @alert.tweet_alert
        end
      end

      describe "and order paper in the past" do
        it 'should not send an update via twitter and not save alert' do
          @alert.stub!(:in_past?).and_return true
          Twfynz.should_not_receive(:twitter_update)
          @alert.should_not_receive(:save!)
          @alert.tweet_alert
        end
      end
    end
    describe "for the second time on an alert date and order paper is not in the past" do
      before do
        @alert.stub!(:in_past?).and_return false
      end
      it 'should not send an update via twitter and not save alert' do
        OrderPaperAlert.should_receive(:find_all_by_name_and_alert_date).with(@name, @alert_date).and_return [mock('alert')]
        Twfynz.should_not_receive(:twitter_update)
        @alert.should_not_receive(:save!)
        @alert.tweet_alert
      end
    end
  end
end
