require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do

  describe 'when asked for home' do
    it 'should generate request from url' do
      assert_routing("/" , :controller => "application" , :action => "home" )
    end
  end

  describe 'when asked for single_date' do
    it 'should generate request from url' do
      assert_routing("/2008-07-01" , :controller => "application" , :action => "show_single_date", :date => '2008-07-01' )
    end
  end

  describe 'host is parlywords.org.nz' do
    before do
      controller.stub!(:is_parlywords_request?).and_return true
    end
    describe 'when asked for home' do
      def do_get
        get :home
      end
      it 'should be successful' do
        do_get
        response.should be_success
      end
      it 'should render parlywords template' do
        do_get
        # response.should render_template('parlywords')
        response.body.should == 'coming soon'
      end
    end
    describe 'when asked for single_date' do
      before do
        @date_param = '2008-07-01'
        @date_label = '1 Jul 2008'
        @date = Date.parse(@date_param)
      end
      def do_get
        get :show_single_date, :date => @date_param
      end
      it 'should check SittingDay for presence of parlywords' do
        SittingDay.should_receive(:has_parlywords?).with(@date).and_return false
        do_get
      end
      describe 'and there are no parly words on date' do
        before do
          SittingDay.stub!(:has_parlywords?).and_return false
        end
        it 'should show 404' do
          do_get
          response.status.should == "404 Not Found"
        end
      end
      describe 'and there are parly words on date' do
        before do
          SittingDay.stub!(:has_parlywords?).and_return true
        end
        it 'should be successful' do
          do_get
          response.should be_success
        end
        it 'should render parlywords template' do
          do_get
          response.should render_template('parlywords_on_date')
        end
        it 'should assign date to view' do
          do_get
          assigns[:date].should == @date_param
        end
        it 'should assign date_label to view' do
          do_get
          assigns[:date_label].should == @date_label
        end
      end
    end
  end

  describe 'host is theyworkforyou.co.nz' do
    before do
      Parliament.stub!(:latest).and_return mock(Parliament, :ordinal=>'48th')
      controller.stub!(:is_parlywords_request?).and_return false
    end
    describe 'when asked for home' do
      def do_get
        get :home
      end
      it 'should be successful' do
        do_get
        response.should be_success
      end
      it 'should render home template' do
        do_get
        response.should render_template('home')
      end
    end
    describe 'when asked for single_date' do
    end
  end

end
