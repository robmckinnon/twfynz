require File.dirname(__FILE__) + '/../spec_helper'

describe DebatesController, 'when receiving request for debate using index number' do

  it 'should redirect to the corresponding category and slug url' do
    year = '2008'
    month = 'may'
    day = '14'
    index = '24'
    date = mock('date', :is_valid_date? => true)

    Debate.stub!(:index_id).and_return index
    DebateDate.stub!(:new).and_return date

    debate = mock_model(DebateAlone)
    id_hash = {:day=>day, :month=>month, :year=>year, :url_category => 'general_debate', :url_slug => nil}
    debate.should_receive(:id_hash).and_return id_hash
    Debate.should_receive(:find_by_date_and_index).with(date, index).and_return debate

    get 'redirect_show_debate', :controller => 'debates', :action=>'redirect_show_debate', :day=>day, :month=>month, :year=>year, :index => index
    response.should redirect_to(show_debates_on_date_url(id_hash))
  end
end

describe DebatesController, 'when getting show_debate' do

  def check_category_params url
    check_params url, :url_category => url.split('/')[1], :url_slug => url.split('/').last
  end

  def get_params params
    {:controller => 'debates', :action=>'show_debate', :day=>'17', :month=>'apr', :year=>'2008'}.merge(params)
  end

  def check_params url, params
    params_from(:get, url).should == get_params(params)
  end

  def check_route url, params
    route_params = get_params(params)
    route_url = route_for(route_params)
    route_url.should == url
  end

  it 'should generate route from category and slug' do
    check_route '/points_of_order/2008/apr/17/mispronunciation', :url_category => 'points_of_order', :url_slug => 'mispronunciation'
  end

  it 'should generate route from category' do
    # check_route '/general_debate/2008/apr/17', :url_category => 'general_debate', :url_slug => nil
    # TODO check_route '/general_debate/2008/apr/17', :url_category => 'general_debate'
  end

  it 'should show debate given date and index' do
    check_params '/debates/2008/apr/17/01', :index => '01', :action => 'redirect_show_debate'
    check_params '/debates/2008/apr/17/06', :index => '06', :action => 'redirect_show_debate'
  end

  it 'should find params for bill debate' do
    check_params '/bills/summary_offences_tagging_graffiti/2008/apr/17/first_reading_1', :url_slug=>'first_reading_1', :action =>'show_bill_debate', :bill_url=>'summary_offences_tagging_graffiti'
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

    check_category_params '/debates/2008/apr/17/voting'
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

  it 'should find debate by date, category' do
    category = 'general_debate'
    slug = nil
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
    check_category_params '/debates/2008/apr/17'
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

describe DebatesController, 'when getting show_debates_by_category' do
  def check_params url, params={}
    params_from(:get, url).should == {:controller => 'debates', :action=>'show_debates_by_category', :url_category => url.split('/')[1]}
  end

  it 'should show debates given category' do
    check_params '/points_of_order'
    check_params '/visitors'
    check_params '/urgent_debates_declined'
    check_params '/tabling_of_documents'
    check_params '/obituaries'
    check_params '/speakers_rulings'
    check_params '/motions'
    check_params '/personal_explanations'
    check_params '/appointments'
    check_params '/urgent_debates'
    check_params '/privilege'
    check_params '/speakers_statements'
    check_params '/resignations'
    check_params '/ministerial_statements'
    check_params '/adjournment'
    check_params '/parliamentary_service_commission'
  end
end
