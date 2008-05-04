require File.dirname(__FILE__) + '/../spec_helper'

def dummy_bill_params
  {:bill_name => 'Major Events Management Bill',
        :parliament_url => '2/5/c/25c94892184b4eb3b38f3d4c465e200d.htm',
        :introduction => '2006-12-12',
        :mp_name => 'Rod Donald'}
end

describe Debate, " destroy" do

  it 'should destroy child sub-debates, contributions, debate topics, votes, and vote casts' do
    date = Date.new(2007,8,29)
    debate = ParentDebate.new :name => 'Dummy', :sub_name => 'Dummier', :debate_index => 1, :date => date
    debate.valid?
    contribution = Procedural.new :text => 'Dumb'

    placeholder = VotePlaceholder.new :text => 'a vote'
    vote = Vote.new :vote_question => 'on nothing', :vote_result => 'nothing'
    cast = VoteCast.new :cast => 'aye', :cast_count => 1

    vote.vote_casts << cast
    vote.contribution = placeholder
    placeholder.vote = vote

    debate.sub_debate.contributions << contribution
    debate.sub_debate.contributions << placeholder
    debate.save!

    bill = Bill.new dummy_bill_params
    Mp.should_receive(:from_name).and_return(mock_model(Mp))
    bill.save!
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
