require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed Electoral Finance Bill - First Reading" do
  include ParserHelperMethods

  before do
    @name = 'Electoral Finance Bill'
    @sub_name = 'First Reading'
    @class = BillDebate
    @css_class = 'billdebate'
    @publication_status = 'F'
    @bill_id = 111
    @date = Date.new(2007,7,26)

    @debate_index = 1
    @file_name = 'nil'
    def_parties
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it 'should determine missing question text' do
    HansardParser.stub!(:load_file).and_return html
    debate = parse_debate
    voteplaceholder = debate.sub_debate.contributions.first
    voteplaceholder.should be_an_instance_of(VotePlaceholder)
    vote = voteplaceholder.vote
    vote.reason.should == 'A party vote was called for on the question, '
    vote.question.should == 'That the Electoral Finance Bill be now read a first time'
    vote.result.should == 'Bill read a first time.'
    vote.ayes_count.should == 65
    vote.noes_count.should == 54
    vote.abstentions_count.should == 0
  end

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - Electoral Finance Bill — First Reading</title>
<meta name="DC.Date" content="2007-07-26T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Electoral Finance Bill — First Reading</h1>
    <a name="DocumentReference"></a>
    <p>[Volume:640;Page:10775]</p>
    <div class="BillDebate">
      <h2>Electoral Finance Bill</h2>
      <div class="SubDebate">
        <h3>First Reading</h3>
        <div class="partyVote">
          <table class="table vote">
            <caption>
              <p>A party vote was called for on the question, That the Electoral Finance Bill be now read a first time</p>
            </caption>
            <tbody>
              <tr><td class="VoteCount">Ayes 65</td>
                <td class="VoteText">New Zealand Labour 49; New Zealand First 7; Green Party 6; United Future 2; Progressive 1.</td>
              </tr>
              <tr><td class="VoteCount">Noes 54</td>
                <td class="VoteText">New Zealand National 48; Māori Party 4; Independents: Copeland, Field.</td>
              </tr>
            </tbody>
            <tfoot>
              <tr><td class="VoteResult" colspan="2">Bill read a first time.</td></tr>
            </tfoot>
          </table>
          <ul class="">
            <li>Bill referred to the Justice and Electoral Committee.</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</div>
</html>
</body>
</html>|
  end
end
