require File.dirname(__FILE__) + '/../spec_helper'

describe UrlItem do

  describe 'when finding title from URL path' do

    def mock_analytics_item(path)
      mock('item', :path => path)
    end

    def mock_bill
      bill_url = %Q|crimes_abolition_of_force_justification|
      item = mock_analytics_item("/bills/#{bill_url}")
      title = 'Crimes (Substituted Section 59) Amendment Bill'
      bill = mock('Bill',:bill_name => title)
      Bill.should_receive(:find_by_url).with(bill_url).and_return(bill)
      return item, title
    end

    it 'should find bill title' do
      analytics_item, title = mock_bill
      item = UrlItem.new(analytics_item)
      item.title.should == title
      item.date.should be_nil
    end

    it 'should find submissions on bill title' do
      path, title = mock_bill
      item = UrlItem.new(path)
      item.title.should == title
      item.date.should be_nil
    end

    it 'should find portfolio debate title' do
      portfolio_url = 'climate_change'
      url_slug = 'emissions_trading_scheme'
      path = "/portfolios/#{portfolio_url}/2008/may/14/#{url_slug}"
      title = 'Emissions Trading Scheme—Transport Sector'
      debate = mock('debate', :name => title)
      Debate.should_receive(:find_by_about_on_date_with_slug).with(Portfolio, portfolio_url, an_instance_of(DebateDate), url_slug).and_return(debate)

      item = UrlItem.new(mock_analytics_item(path))
      item.title.should == title
      item.date.should == Date.new(2008,5,14)
    end

    it 'should find bill debate title' do
      bill_url = 'kiwisaver'
      url_slug = 'first_reading'
      path = "/bills/#{bill_url}/2006/mar/02/#{url_slug}"
      bill_name = %Q|KiwiSaver Bill|
      debate_name = %Q|First Reading|
      title = "#{bill_name}, #{debate_name}"
      debate = mock('debate', :name => debate_name, :parent_name=>bill_name)
      Debate.should_receive(:find_by_about_on_date_with_slug).with(Bill, bill_url, an_instance_of(DebateDate), url_slug).and_return(debate)

      item = UrlItem.new(mock_analytics_item(path))
      item.title.should == title
      item.date.should == Date.new(2006,3,2)
    end

    # /appointments/2008/apr/17/chief_ombudsman
    it 'should find url_category debate title' do
      url_slug = 'chief_ombudsman'
      url_category = 'appointments'
      path = "/#{url_category}/2006/mar/02/#{url_slug}"
      parent_name = 'Appointments'
      debate_name = 'Chief Ombudsman'
      debate = mock('debate', :name => debate_name, :parent_name=>parent_name)
      Debate.should_receive(:find_by_url_category_and_url_slug).with(an_instance_of(DebateDate), url_category, url_slug).and_return(debate)

      item = UrlItem.new(mock_analytics_item(path))
      item.title.should == "#{parent_name}, #{debate_name}"
      item.date.should == Date.new(2006,3,2)
    end

    # /debates/2008/jun/17
    it 'should find debates on day title' do
      path = "/debates/2008/jun/17"
      Debate.should_receive(:find_by_date).with('2008','jun','17').and_return [mock_model(OralAnswers)]

      item = UrlItem.new(mock_analytics_item(path))
      item.title.should == "Questions for Oral Answer, 17 June 2008"
      item.date.should == Date.new(2008,6,17)
    end
  end

end
