require File.dirname(__FILE__) + '/../spec_helper'

describe OralAnswer, "creating url slug" do

  it 'should use the debate name' do
    assert_slug_correct 'music', 'music'
  end

  it 'should use lower case version of debate name' do
    assert_slug_correct 'Music', 'music'
  end

  it 'should latinized maori long vowel characters' do
    assert_slug_correct 'Māori Wardens—Capacity Increases', 'maori_wardens'
  end

  it 'should replace spaces in debate name with underscores in url slug' do
    assert_slug_correct 'Music Awards', 'music_awards'
  end

  it 'should use debate name up to — character' do
    assert_slug_correct 'Music Awards—Prime Minister', 'music_awards'
  end

  it 'should remove and from debate name' do
    assert_slug_correct 'Information and Communications Technology—Community Capability and Skill', 'information_communications_technology'
  end

  it 'should leave - from debate name unchanged' do
    assert_slug_correct 'Non-proliferation—United Nations', 'non-proliferation'
  end

  it 'should use debate name after — character if first part is a minister\'s title' do
    assert_slug_correct_with_about 'Corrections, Minister—Confidence in Department', 'confidence_in_department', :portfolio => 'Corrections'
  end

  it 'should use debate name after — character if first part is an associate minister\'s title' do
    assert_slug_correct_with_about 'Arts, Culture and Heritage, Associate Minister—Attendance at Events', 'attendance_at_events', :portfolio => 'Arts, Culture and Heritage'
  end

  it 'should use debate name after — character if first part is name of the portfolio' do
    assert_slug_correct_with_about 'Community and Voluntary Sector—Relationships with Government', 'relationships_with_government', :portfolio => 'Community and Voluntary Sector'
  end

  it 'should use debate name after — character if first part is name of the portfolio ignoring commas' do
    assert_slug_correct_with_about 'Research, Science, and Technology—Contestable Government Funding', 'contestable_government_funding', :portfolio => 'Research, Science and Technology'
  end

  it 'should use debate name after — character if first part is name of the bill' do
    assert_slug_correct_with_about 'Employment Relations (Probationary Employment) Amendment Bill—Purpose', 'purpose', :bill => 'Employment Relations (Probationary Employment) Amendment Bill'
  end

  it 'should use debate name after — character if first part is name of the committee' do
    assert_slug_correct_with_about 'Finance and Expenditure Committee—Television New Zealand Inquiry', 'television_nz_inquiry', :committee => 'Finance and Expenditure Committee'
  end

  it 'should append url slug with _2 if second occurance of slug on same day with same publication status' do
    assert_slug_correct_with_about 'Electoral Finance Bill—Prime Minister’s Comments', 'electoral_finance_bill', :portfolio => 'Prime Minister'

    OralAnswer.should_receive(:find_by_url_slug_and_date_and_publication_status_and_about_type_and_about_id).
      with('electoral_finance_bill', @answer.date, @answer.publication_status, @answer.about_type, @answer.about_id).and_return @answer
    @answer.should_receive(:url_slug=).with('electoral_finance_bill_1')
    @answer.should_receive(:save!)

    OralAnswer.should_receive(:find_by_url_slug_and_date_and_publication_status_and_about_type_and_about_id).
      with('electoral_finance_bill_2', @answer.date, @answer.publication_status, @answer.about_type, @answer.about_id).and_return nil


    assert_slug_correct_with_about 'Electoral Finance Bill—Consequences of Overspending', 'electoral_finance_bill_2', :portfolio => 'Prime Minister'
  end

  it 'should append url slug with _3 if third occurance of slug on same day with same publication status' do
    assert_slug_correct_with_about 'Electoral Finance Bill—Prime Minister’s Comments', 'electoral_finance_bill', :portfolio => 'Prime Minister'

    OralAnswer.should_receive(:find_by_url_slug_and_date_and_publication_status_and_about_type_and_about_id).
      with('electoral_finance_bill', @answer.date, @answer.publication_status, @answer.about_type, @answer.about_id).and_return nil
    OralAnswer.should_receive(:find_by_url_slug_and_date_and_publication_status_and_about_type_and_about_id).
      with('electoral_finance_bill_1', @answer.date, @answer.publication_status, @answer.about_type, @answer.about_id).and_return @answer
    OralAnswer.should_receive(:find_by_url_slug_and_date_and_publication_status_and_about_type_and_about_id).
      with('electoral_finance_bill_2', @answer.date, @answer.publication_status, @answer.about_type, @answer.about_id).and_return @answer
    OralAnswer.should_receive(:find_by_url_slug_and_date_and_publication_status_and_about_type_and_about_id).
      with('electoral_finance_bill_3', @answer.date, @answer.publication_status, @answer.about_type, @answer.about_id).and_return nil
    assert_slug_correct_with_about 'Electoral Finance Bill—Consequences of Underspending', 'electoral_finance_bill_3', :portfolio => 'Prime Minister'
  end

  def assert_slug_correct name, expected
    @answer = new_answer name
    @answer.create_url_slug
    @answer.url_slug.should == expected
  end

  def assert_slug_correct_with_about name, expected, about
    about_type = about.keys.first
    about_name = about.values.first
    about_class = Object.const_get(about_type.to_s.capitalize)
    about = mock(about_class)
    about.stub!(:full_name).and_return about_name
    about.stub!(:class).and_return about_class

    @answer = new_answer name
    @answer.stub!(:about).and_return about
    @answer.stub!(:about_type).and_return about_class.name
    @answer.stub!(:about_id).and_return 21
    @answer.create_url_slug
    @answer.url_slug.should == expected
  end

  def new_answer name
    OralAnswer.new(:name => name, :date => '2008-04-01', :publication_status => 'U', :debate => mock_model(OralAnswers, :name=>'Questions for Oral Answer') )
  end
end
