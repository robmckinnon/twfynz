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
        response.should render_template('parlywords')
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
          response.headers["Status"].should == "404 Not Found"
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

  describe 'when finding title from URL path' do
    def mock_bill
      bill_url = %Q|crimes_abolition_of_force_justification|
      path = "/bills/#{bill_url}"
      title = 'Crimes (Substituted Section 59) Amendment Bill'
      bill = mock('Bill',:bill_name => title)
      Bill.should_receive(:find_by_url).with(bill_url).and_return(bill)
      return path, title
    end

    it 'should find bill title' do
      path, title = mock_bill
      ApplicationController.title_from_path(path).should == title
    end

    it 'should find submissions on bill title' do
      path, title = mock_bill
      ApplicationController.title_from_path(path).should == title
    end

    it 'should find portfolio debate title' do
      portfolio_url = 'climate_change'
      url_slug = 'emissions_trading_scheme'
      path = "/portfolios/#{portfolio_url}/2008/may/14/#{url_slug}"
      title = 'Emissions Trading Scheme—Transport Sector'
      debate = mock('debate', :name => title)
      date = mock('date')
      DebateDate.should_receive(:new).and_return date
      Debate.should_receive(:find_by_about_on_date_with_slug).with(Portfolio, portfolio_url, date, url_slug).and_return(debate)

      ApplicationController.title_from_path(path).should == title
    end

    it 'should find bill debate title' do
      bill_url = 'kiwisaver'
      url_slug = 'first_reading'
      path = "/bills/#{bill_url}/2006/mar/02/#{url_slug}"
      bill_name = %Q|KiwiSaver Bill|
      debate_name = %Q|First Reading|
      title = "#{bill_name}, #{debate_name}"
      debate = mock('debate', :name => debate_name, :parent_name=>bill_name)
      date = mock('date')
      DebateDate.should_receive(:new).and_return date
      Debate.should_receive(:find_by_about_on_date_with_slug).with(Bill, bill_url, date, url_slug).and_return(debate)

      ApplicationController.title_from_path(path).should == title
    end

    # /appointments/2008/apr/17/chief_ombudsman
    it 'should find url_category debate title' do
      url_slug = 'chief_ombudsman'
      url_category = 'appointments'
      path = "/#{url_category}/2006/mar/02/#{url_slug}"
      date = mock('date')
      DebateDate.should_receive(:new).and_return date
      parent_name = 'Appointments'
      debate_name = 'Chief Ombudsman'
      debate = mock('debate', :name => debate_name, :parent_name=>parent_name)
      Debate.should_receive(:find_by_url_category_and_url_slug).with(date, url_category, url_slug).and_return(debate)

      ApplicationController.title_from_path(path).should == "#{parent_name}, #{debate_name}"
    end

    # /debates/2008/jun/17
    it 'should find debates on day title' do
      path = "/debates/2008/jun/17"
      date = mock('date',:year=>'2007',:month=>'jun',:day=>'17',:to_date=>Date.new(2008,6,17))
      DebateDate.should_receive(:new).and_return date
      Debate.should_receive(:find_by_date).with('2007','jun','17').and_return [mock_model(OralAnswers)]

      ApplicationController.title_from_path(path).should == "Questions for Oral Answer, 17 June 2008"
    end
  end

end
