require File.dirname(__FILE__) + '/../spec_helper'

describe DebateAlone, "creating url slug" do

  it 'should use the debate name' do
    assert_slug_correct 'Address in Reply', 'address_in_reply'
  end

  it 'should use the second part of debate name if it starts with "Address in Reply—"' do
    assert_slug_correct 'Address in Reply—Presentation to Governor-General', 'presentation_to_governor-general'
  end

  it 'should use the second part of debate name if it starts with "Offices of Parliament—"' do
    assert_slug_correct 'Offices of Parliament—Address to Governor-General', 'address_to_governor-general'
  end

  it 'should remove "’" character when making slug' do
    assert_slug_correct 'Debate on Prime Minister’s Statement', 'debate_on_prime_ministers_statement'
  end

  it 'should include all text if name includes " — "' do
    assert_slug_correct 'Members’ Bills — Procedure', 'members_bills_procedure'
  end

  it 'should include all text if name includes "—"' do
    assert_slug_correct 'Standing Orders—Sessional', 'standing_orders_sessional'
  end

  def assert_slug_correct name, expected
    debate = DebateAlone.new(:name => name, :date => '2008-04-01', :publication_status => 'U')
    debate.create_url_slug
    debate.url_slug.should == expected
  end
end


