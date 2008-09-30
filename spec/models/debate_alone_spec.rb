require File.dirname(__FILE__) + '/../spec_helper'

describe DebateAlone do

  describe 'when asked for bill' do
    describe 'and has no debate_topics' do
      it 'should return nil' do
        debate = DebateAlone.new
        debate.should_receive(:debate_topics).and_return []
        debate.bill.should be_nil
      end
    end
    describe 'and is not about bill' do
      it 'should return nil' do
        debate = DebateAlone.new
        bill = mock('bill')
        topic1 = mock('debatetopic1', :formerly_part_of_bill => bill)
        topic2 = mock('debatetopic2', :formerly_part_of_bill => bill)
        debate.should_receive(:debate_topics).and_return [topic1, topic2]
        debate.bill.should == bill
      end
    end
  end

  describe "creating url slug" do
    it 'should set category for frequent debate names' do
      assert_category_correct 'Business Statement',    'business_statement'
      assert_category_correct 'General Debate',        'general_debate'
      assert_category_correct 'Business of the House', 'business_of_the_house'
      assert_category_correct 'Sittings of the House', 'sittings_of_the_house'
      assert_category_correct 'Members Sworn',         'members_sworn'
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

    it 'should set category for variants of frequent debate names' do
      assert_category_correct 'Member Sworn', 'members_sworn'
    end

    it 'should set category and slug for frequent debate names' do
      assert_slug_correct 'Standing Orders—Sessional',  'standing_orders', 'sessional'
      assert_slug_correct 'Standing Orders—Suspension', 'standing_orders', 'suspension'
      assert_slug_correct 'Members’ Bills — Procedure', 'members_bills', 'procedure'
      assert_slug_correct 'Offices of Parliament—Address to Governor-General', 'offices_of_parliament', 'address_to_governor-general'
      assert_slug_correct 'Address in Reply—Presentation to Governor-General', 'address_in_reply', 'presentation_to_governor-general'
    end

    it 'should set category and slug for variants of frequent debate names' do
      assert_slug_correct 'Offices of Parliament — Address to Governor-General', 'offices_of_parliament', 'address_to_governor-general'
      assert_slug_correct 'Address in Reply—Presentation to Governor-GENERAL', 'address_in_reply', 'presentation_to_governor-general'
    end

    it 'should set slug to part_1 and part_2 if there are two parts to a debate with same category' do
      assert_category_correct 'General Debate',        'general_debate'
    end

    it 'should not set category for other frequent debate names' do
      assert_slug_correct 'Third Readings', 'third_readings'
      assert_slug_correct 'Urgency', 'urgency'
    end

    def assert_category_correct name, category
      assert_slug_correct name, category, ''
    end

    def assert_slug_correct name, category_or_slug, slug=nil
      category = slug ? category_or_slug : nil
      slug = (slug ? (slug.blank? ? nil : slug) : category_or_slug)
      publication_status = 'U'
      date = Date.parse('2008-04-01')

      if category && slug.blank?
        lookup_method = :find_all_by_url_category_and_date_and_publication_status
        Debate.should_receive(lookup_method).with(category, date, publication_status).and_return []
      end
      unless slug.blank?
        lookup_method = :find_by_url_category_and_url_slug_and_date_and_publication_status
        Debate.should_receive(lookup_method).with(category, slug, date, publication_status).and_return nil
        Debate.should_receive(lookup_method).with(category, slug+'_1', date, publication_status).and_return nil
      end

      debate = DebateAlone.new(:name => name, :date => date, :publication_status => publication_status)
      debate.create_url_slug
      debate.url_category.should == category if category
      debate.url_slug.should == slug
    end
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
