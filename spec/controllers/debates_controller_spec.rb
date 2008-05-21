require File.dirname(__FILE__) + '/../spec_helper'

describe DebatesController, 'when getting show_debate' do
  def check_category_params url
    check_params url, :url_category => url.split('/')[1], :url_slug => url.split('/').last
  end

  def check_params url, params
    params_from(:get, url).should == {:controller => 'debates', :action=>'show_debate', :day=>'17', :month=>'apr', :year=>'2008'}.merge(params)
  end

  it 'should show debate given date and index' do
    check_params '/debates/2008/apr/17/01', :index => '01', :action => 'redirect_show_debate'
  end

  it 'should show debate given category, date and slug' do
    check_category_params '/points_of_order/2008/apr/17/mispronunciation'  # http://theyworkforyou.co.nz/debates/2008/apr/09/02
    check_category_params '/visitors/2008/apr/17/australia'  # http://localhost:3000/debates/2008/apr/15/01
    check_category_params '/urgent_debates_declined/2008/apr/17/auckland_international_airport'  # http://theyworkforyou.co.nz/debates/2008/apr/15/20
    check_category_params '/tabling_of_documents/2008/apr/17/driving_incident'  # http://theyworkforyou.co.nz/debates/2008/apr/02/23
    check_category_params '/obituaries/2008/apr/17/fraser_macdonald_colman'   # http://theyworkforyou.co.nz/debates/2008/apr/15/03
    check_category_params '/speakers_rulings/2008/apr/17/personal_explanations'   # http://theyworkforyou.co.nz/debates/2008/apr/01/02
    check_category_params '/motions/2008/apr/17/tongariro_tragedy'  # http://theyworkforyou.co.nz/debates/2008/apr/16/01
    check_category_params '/personal_explanations/2008/apr/17/electoral_finance_act' # http://theyworkforyou.co.nz/debates/2008/apr/02/21
    check_category_params '/appointments/2008/apr/17/chief_ombudsman' # http://theyworkforyou.co.nz/debates/2008/apr/17/17
    check_category_params '/urgent_debates/2008/apr/17/hawkes_bay_district_health' # http://theyworkforyou.co.nz/debates/2008/mar/18/25
    check_category_params '/privilege/2008/apr/17/contempt_of_house' # http://theyworkforyou.co.nz/debates/2007/mar/13/02
    check_category_params '/speakers_statements/2008/apr/17/microphones_in_chamber' # http://theyworkforyou.co.nz/debates/2007/sep/19/26
    check_category_params '/resignations/2008/apr/17/dianne_yates' # http://theyworkforyou.co.nz/debates/2008/apr/01/04
    check_category_params '/ministerial_statements/2008/apr/17/fiji' # http://theyworkforyou.co.nz/debates/2007/jun/14/03
    check_category_params '/adjournment/2008/apr/17/sittings_of_the_house' # http://theyworkforyou.co.nz/debates/2007/dec/18/29
    check_category_params '/parliamentary_service_commission/2008/apr/17/membership' # http://theyworkforyou.co.nz/debates/2008/feb/19/23
  end

  it 'should find debate by date, category and slug' do
    category = 'visitors'
    slug = 'australia'
    year = '2008'; month = 'apr'; day = '17'
    date = mock(DebateDate, :year=>year, :month=>month, :day=>day, :is_valid_date? => true)
    DebateDate.stub!(:new).and_return date
    debate = mock_model(SubDebate, :debate => mock_model(ParentDebate))
    Debate.should_receive(:find_by_url_category_and_url_slug).with(date, category, slug).and_return debate
    get 'show_debate', :controller => 'debates', :action=>'show_debate', :day=>day, :month=>month, :year=>year, :url_category => category, :url_slug => slug
    assigns[:debate].should == debate
    assigns[:date].should == date
  end
end

describe DebatesController, 'when getting show_debates_on_date' do
  def check_category_params url
    check_params url, :url_category => url.split('/')[1]
  end

  def check_params url, params={}
    params_from(:get, url).should == {:controller => 'debates', :action=>'show_debates_on_date', :day=>'17', :month=>'apr', :year=>'2008'}.merge(params)
  end

  it 'should show debates on date given date' do
    check_params '/debates/2008/apr/17'
  end

  it 'should show debates on date given category and date' do
    check_category_params '/points_of_order/2008/apr/17'
    check_category_params '/visitors/2008/apr/17'
    check_category_params '/urgent_debates_declined/2008/apr/17'
    check_category_params '/tabling_of_documents/2008/apr/17'
    check_category_params '/obituaries/2008/apr/17'
    check_category_params '/speakers_rulings/2008/apr/17'
    check_category_params '/motions/2008/apr/17'
    check_category_params '/personal_explanations/2008/apr/17'
    check_category_params '/appointments/2008/apr/17'
    check_category_params '/urgent_debates/2008/apr/17'
    check_category_params '/privilege/2008/apr/17'
    check_category_params '/speakers_statements/2008/apr/17'
    check_category_params '/resignations/2008/apr/17'
    check_category_params '/ministerial_statements/2008/apr/17'
    check_category_params '/adjournment/2008/apr/17'
    check_category_params '/parliamentary_service_commission/2008/apr/17'
  end
end
