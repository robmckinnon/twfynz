require File.dirname(__FILE__) + '/../spec_helper'

describe DebateAlone, "creating url slug" do

  it 'should use the second part of debate name if it starts with "Address in Reply—"' do
    assert_slug_correct 'Address in Reply—Presentation to Governor-General', 'presentation_to_governor-general'
    assert_slug_correct 'Address in Reply—Presentation to Governor-GENERAL', 'presentation_to_governor-general'
  end

  it 'should use the second part of debate name if it starts with "Offices of Parliament—"' do
    assert_slug_correct 'Offices of Parliament—Address to Governor-General', 'address_to_governor-general'
  end

  it 'should set category for frequent debate names' do
    assert_category_correct 'Business Statement',    'business_statement'
    assert_category_correct 'General Debate',        'general_debate'
    assert_category_correct 'Business of the House', 'business_of_the_house'
    assert_category_correct 'Sittings of the House', 'sittings_of_the_house'
    assert_category_correct 'Members Sworn',         'members_sworn'
    assert_category_correct 'Member Sworn',         'members_sworn'
    assert_category_correct 'Address in Reply',      'address_in_reply'
    assert_category_correct 'Debate on Prime Minister’s Statement', 'debate_on_prime_ministers_statement'
    assert_category_correct 'List Member Vacancy',   'list_member_vacancy'
    assert_category_correct 'Budget Debate',         'budget_debate'
    assert_category_correct 'Maiden Statement',      'maiden_statement'
    assert_category_correct 'Valedictory Statement', 'valedictory_statement'
    assert_category_correct 'Members’ Bills', 'members_bills'
    assert_category_correct 'Prime Minister’s Statement', 'prime_ministers_statement'
    assert_category_correct 'Debate on Budget Policy Statement', 'debate_on_budget_policy_statement'
    assert_category_correct 'Adjournment', 'adjournment'
    assert_category_correct 'State Opening', 'state_opening'
    assert_category_correct 'Reinstatement of Business', 'reinstatement_of_business'
    assert_category_correct 'Officers of Parliament', 'officers_of_parliament'
    assert_category_correct 'Business of Select Committees', 'business_of_select_committees'
    assert_category_correct 'Commission Opening of Parliament', 'commission_opening_of_parliament'
  end

  it 'should set category and slug for frequent debate names' do
    assert_slug_correct 'Standing Orders—Sessional',  'standing_orders', 'sessional'
    assert_slug_correct 'Standing Orders—Suspension', 'standing_orders', 'suspension'
    assert_slug_correct 'Members’ Bills — Procedure', 'members_bills', 'procedure'
    assert_slug_correct 'Offices of Parliament—Address to Governor-General', 'offices_of_parliament', 'address_to_governor-general'
    assert_slug_correct 'Offices of Parliament — Address to Governor-General', 'offices_of_parliament', 'address_to_governor-general'
    assert_slug_correct 'Address in Reply—Presentation to Governor-General', 'address_in_reply', 'presentation_to_governor-general'
    assert_slug_correct 'Address in Reply—Presentation to Governor-GENERAL', 'address_in_reply', 'presentation_to_governor-general'
  end

  it 'should not set category for other frequent debate names' do
    assert_slug_correct 'Third Readings', 'third_readings'
    assert_slug_correct 'Urgency', 'urgency'
  end

  def assert_category_correct name, category
    assert_slug_correct name, category, ''
  end

  def assert_slug_correct name, category_or_slug, slug=nil
    debate = DebateAlone.new(:name => name, :date => '2008-04-01', :publication_status => 'U')
    debate.create_url_slug
    debate.url_category.should == category_or_slug if slug
    debate.url_slug.should == (slug ? (slug.blank? ? nil : slug) : category_or_slug)
  end
end

=begin
Debate on Budget Policy Statement 3
Election of Speaker 2
Authority to Administer Oath 2
Standing Orders—Suspension 2
Offices of Parliament—Address to Governor-General 2
Member Sworn 1
Governor-General’s Speech 1
Members’ Bills — Procedure 1
Naming of Member 1
Commission Opening of Parliament 1
Officers of Parliament 1
Business of Select Committees 1
Offices of Parliament — Address to Governor-General 1
Reinstatement of Business 1
State Opening 1
Adjournment 1
Address in Reply—Presentation to Governor-General 1
Address in Reply—Presentation to Governor-GENERAL 1
presentation of report 1


Business Statement 65
General Debate 61
Business of the House 27
Third Readings 14
Sittings of the House 13
Debate on Prime Minister’s Statement 11
Members Sworn 9
Address in Reply 8
Budget Debate 8
Urgency 7
List Member Vacancy 7
Standing Orders—Sessional 6
Maiden Statement 4
Valedictory Statement 4
Members’ Bills 3
Prime Minister’s Statement 3
=end
