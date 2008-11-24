require File.dirname(__FILE__) + '/../spec_helper'

def dummy_bill_params
  {:bill_name => 'Major Events Management Bill',
        :parliament_url => '2/5/c/25c94892184b4eb3b38f3d4c465e200d.htm',
        :parliament_id => '2/5/c/25c94892184b4eb3b38f3d4c465e200d.htm',
        :introduction => '2006-12-12',
        :mp_name => 'Rod Donald'}
end

describe Debate, "when being destroyed" do

  before(:all) do
    Debate.delete_all
    DebateTopic.delete_all
    Contribution.delete_all
    Vote.delete_all
    VoteCast.delete_all
    Bill.delete_all
  end

  it 'should destroy child sub-debates, contributions, debate topics, votes, and vote casts' do
    date = Date.new(2007,8,29)
    debate = ParentDebate.new :name => 'Dummy', :sub_name => 'Dummier', :debate_index => 1, :date => date, :publication_status => 'F', :css_class => 'debate'
    debate.valid?
    contribution = Procedural.new :text => 'Dumb'

    placeholder = VotePlaceholder.new :text => 'a vote'
    vote = Vote.new :vote_question => 'on nothing', :vote_result => 'nothing'
    cast = VoteCast.new :cast => 'aye', :cast_count => 1, :vote_label => 'Party Name'

    vote.vote_casts << cast
    vote.contribution = placeholder
    placeholder.vote = vote

    debate.sub_debate.contributions << contribution
    debate.sub_debate.contributions << placeholder
    debate.save!

    Mp.should_receive(:from_name).and_return(mock_model(Mp))
    bill = GovernmentBill.create dummy_bill_params
    topic = DebateTopic.new
    topic.topic = bill
    topic.debate = debate
    topic.save!

    id = debate.id

    debate = Debate.find(id)

    debate.sub_debate.should_not be_nil
    debate.sub_debate.contributions.first.should_not be_nil
    debate.sub_debate.contributions.last.should_not be_nil
    debate.sub_debate.contributions.last.vote.should_not be_nil
    debate.sub_debate.contributions.last.vote.vote_casts.first.should_not be_nil

    Debate.find(:all).size.should == 2
    DebateTopic.find(:all).size.should == 1
    Contribution.find(:all).size.should == 2
    Vote.find(:all).size.should == 1
    VoteCast.find(:all).size.should == 1
    Bill.find(:all).size.should == 1

    debate.destroy

    Debate.find(:all).size.should == 0
    DebateTopic.find(:all).size.should == 0
    Contribution.find(:all).size.should == 0
    Vote.find(:all).size.should == 0
    VoteCast.find(:all).size.should == 0
    Bill.find(:all).size.should == 1
  end

  after(:all) do
    Debate.delete_all
    DebateTopic.delete_all
    Contribution.delete_all
    Vote.delete_all
    VoteCast.delete_all
    Bill.delete_all
  end
end

describe Debate, 'when finding by category and slug' do
  it 'should find using parameters' do
    category = 'visitors'
    url_slug = 'australia'
    year = '2008'; month = 'apr'; day = '17'
    yyyy_mm_dd = "#{year}-04-#{day}"
    date = mock(DebateDate, :year=>year, :month=>month, :day=>day, :is_valid_date? => true, :yyyy_mm_dd => yyyy_mm_dd)
    debate = mock_model(SubDebate)
    debates = [debate]
    Debate.should_receive(:find_all_by_date_and_url_category_and_url_slug).with(yyyy_mm_dd, category, url_slug).and_return debates
    Debate.should_receive(:remove_duplicates).with(debates).and_return debates

    Debate.find_by_url_category_and_url_slug(date, category, url_slug).should == debate
  end

  it 'should find only using slug parameter when category is debates' do
    category = 'debates'
    url_slug = 'voting'
    year = '2008'; month = 'apr'; day = '17'
    yyyy_mm_dd = "#{year}-04-#{day}"
    date = mock(DebateDate, :year=>year, :month=>month, :day=>day, :is_valid_date? => true, :yyyy_mm_dd => yyyy_mm_dd)
    debate = mock_model(SubDebate)
    debates = [debate]
    Debate.should_receive(:find_all_by_date_and_url_slug).with(yyyy_mm_dd, url_slug).and_return debates
    Debate.should_receive(:remove_duplicates).with(debates).and_return debates

    Debate.find_by_url_category_and_url_slug(date, category, url_slug).should == debate
  end
end

describe Debate, 'when finding by date and index' do
  it 'should return subdebate if index is pointing to parent debate with one subdebate' do
    date = mock('date', :year=>'year',:month=>'month',:day=>'day')
    index = mock('index')
    sub_debate = mock('sub_debate')
    parent_debate = mock_model(ParentDebate, :is_parent_with_one_sub_debate? => true, :sub_debate => sub_debate)
    Debate.should_receive(:find_by_index).with('year','month','day',index).and_return parent_debate
    Debate.find_by_date_and_index(date, index).should == sub_debate
  end
end

describe Debate, 'when finding on date by category' do
  it 'should return subdebate if index is pointing to parent debate with one subdebate' do
    date = mock('date', :year=>'year',:month=>'month',:day=>'day')
    index = mock('index')
    sub_debate = mock('sub_debate')
    parent_debate = mock_model(ParentDebate, :is_parent_with_one_sub_debate? => true, :sub_debate => sub_debate)
    Debate.should_receive(:find_by_index).with('year','month','day',index).and_return parent_debate
    Debate.find_by_date_and_index(date, index).should == sub_debate
  end
end

describe Debate, 'in general' do
  it 'should not identify itself as a parent debate with a single sub_debate' do
    debate = Debate.new
    debate.is_parent_with_one_sub_debate?.should be_false
  end

  it "should return contribution_id when contribution is in debate's contributions" do
    debate = Debate.new
    contribution = mock('contribution')
    debate.should_receive(:contribution_index).with(contribution).and_return 1
    debate.contribution_id(contribution).should == '2'
  end

  it "should return contribution_id when contribution is in a sub_debate's contributions" do
    contribution = mock('contribution')
    sub_debate = Debate.new
    sub_debate.should_receive(:contribution_index).with(contribution).and_return 2

    debate = Debate.new
    debate.should_receive(:contribution_index).with(contribution).and_return nil
    debate.should_receive(:sub_debates).twice.and_return [sub_debate]

    debate.contribution_id(contribution).should == '3'
  end

  it 'should return nil for parent name' do
    debate = Debate.new
    debate.parent_name.should be_nil
  end
end
