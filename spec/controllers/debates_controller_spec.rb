require File.dirname(__FILE__) + '/../spec_helper'

describe DebatesController, 'when getting show_debate' do

  def check_category_params url
    check_params url, :category => url.split('/')[1], :slug => url.split('/').last
  end

  def check_params url, params
    params_from(:get, url).should == {:controller => 'debates', :action=>'show_debate', :day=>'17', :month=>'apr', :year=>'2008'}.merge(params)
  end

  it 'should show debate given date and index' do
    check_params '/debates/2008/apr/17/01', :index=>'01'
  end

  it 'should show debate given category, date and slug' do
    check_category_params '/points_of_order/2008/apr/17/mispronunciation'  # http://theyworkforyou.co.nz/debates/2008/apr/09/02
    check_category_params '/visitors/2008/apr/17/australia'  # http://localhost:3000/debates/2008/apr/15/01
    check_category_params '/urgent_debates_declined/2008/apr/17/auckland_international_airport'  # http://theyworkforyou.co.nz/debates/2008/apr/15/20
    check_category_params '/tabling_of_documents/2008/apr/17/driving_incident'  # http://theyworkforyou.co.nz/debates/2008/apr/02/23
    check_category_params '/obituaries/2008/apr/17/fraser_macdonald_colman'   # http://theyworkforyou.co.nz/debates/2008/apr/15/03
    check_category_params '/speakers_rulings/2008/apr/17/personal_explanations'   # http://theyworkforyou.co.nz/debates/2008/apr/01/02
    check_category_params '/motions/2008/apr/17/tongariro_tragedy'  # http://theyworkforyou.co.nz/debates/2008/apr/16/01
  end
end

describe DebatesController, 'when getting show_debates_on_date' do
  def check_category_params url
    check_params url, :category => url.split('/')[1]
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
  end
end
