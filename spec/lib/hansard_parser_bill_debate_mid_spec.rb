require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed debate containing BillDebateMid" do
  include ParserHelperMethods

  before do
    @name = 'Taxation (Annual Rates of Income Tax 2007-08) Bill (No 2), Taxation (Business Taxation, Chewing Gum and Remedial Matters) Bill, Taxation (KiwiSaver) Bill'
    @first_bill_name = 'Taxation (Annual Rates of Income Tax 2007-08) Bill (No 2)'
    @second_bill_name = 'Taxation (Business Taxation, Chewing Gum and Remedial Matters) Bill'
    @third_bill_name = 'Taxation (KiwiSaver) Bill'
    @sub_name = 'Third Readings'
    @class = BillDebate
    @css_class = 'billdebate_mid'
    @publication_status = 'A'
    @bill_id = 111
    @bill_id2 = 112
    @bill_id3 = 113
    @date = Date.new(2007,12,12)
    @debate_index = 1
    @file_name = 'nil'
    def_parties
    HansardParser.stub!(:load_file).and_return html
    @debate = parse_debate
    @sub_debate = @debate.sub_debate
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All parent debates"

  it 'should create a debate with no about' do
    @sub_debate.about_type.should == nil
    @sub_debate.about_id.should == nil
  end

  it 'should create a debate with a debate topic for each bill in reading title' do
    @sub_debate.debate_topics.size.should == 3
  end

  it 'should create a debate with first debate topic correct' do
    @sub_debate.debate_topics[0].topic_type.should == 'Bill'
  end

  it 'should create a debate with second debate topic correct' do
    @sub_debate.debate_topics[1].topic_type.should == 'Bill'
  end

  it 'should create a debate with third debate topic correct' do
    @sub_debate.debate_topics[2].topic_type.should == 'Bill'
  end

  it 'should create a debate with debate topic ids correct' do
    ids = @sub_debate.debate_topics.collect {|t| t.topic_id }
    ids.include?(@bill_id).should be_true
    ids.include?(@bill_id2).should be_true
    ids.include?(@bill_id3).should be_true
  end

  it 'should create party vote correctly' do
    voteplaceholder = @debate.sub_debate.contributions.last
    voteplaceholder.should be_an_instance_of(VotePlaceholder)
    vote = voteplaceholder.vote
    vote.reason.should == 'A party vote was called for on the question, '
    vote.question.should == 'That the Taxation (Annual Rates of Income Tax 2007-08) Bill, the Taxation (Business Taxation and Remedial Matters) Bill, and the Taxation (KiwiSaver) Bill be now read a third time.'
    vote.result.should == 'Bills read a third time.'
    vote.ayes_count.should == 65
    vote.noes_count.should == 50
    vote.abstentions_count.should == 6
  end

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - Taxation (Annual Rates of Income Tax 2007-08) Bill, Taxation (Business Taxation and Remedial Matters) Bill, Taxation (KiwiSaver) Bill — Third Readings</title>
<meta name="DC.Date" content="2007-12-12T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Taxation (Annual Rates of Income Tax 2007-08) Bill (No 2), Taxation (Business Taxation , Chewing Gum and Remedial Matters) Bill, Taxation (KiwiSaver) Bill — Third Readings</h1>
    <a name="DocumentReference"></a>
    <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>

    <div class="BillDebateMid">
      <h2>Taxation (Annual Rates of Income Tax 2007-08) Bill (No 2)</h2>
      <h2>Taxation (Business Taxation, Chewing Gum and Remedial Matters) Bill</h2>
      <h2>Taxation (KiwiSaver) Bill</h2>
      <div class="SubDebate">
        <h3>Third Readings</h3>
        <ul class="">
          <li>Debate resumed.</li>
        </ul>
        <div class="partyVote">
          <table class="table vote">
            <caption>
              <p>A party vote was called for on the question, <em>That the Taxation (Annual Rates of Income Tax 2007-08) Bill, the Taxation (Business Taxation and Remedial Matters) Bill, and the Taxation (KiwiSaver) Bill be now read a third time.</em>
              </p>
            </caption>
            <tbody>
              <tr><td class="VoteCount">Ayes 65</td>
                <td class="VoteText">New Zealand Labour 49; New Zealand First 7; Māori Party 4; United Future 2; Progressive 1; Independents: Copeland, Field.</td>
              </tr>
              <tr><td class="VoteCount">Noes 50</td>
                <td class="VoteText">New Zealand National 48; ACT New Zealand 2.</td>
              </tr>
              <tr><td class="VoteCount">Abstentions 6</td>
                <td class="VoteText">Green Party 6.</td>
              </tr>
            </tbody>
            <tfoot>
              <tr><td class="VoteResult" colspan="2">Bills read a third time.
              </td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>
</div>
</div>
</form>
</div>
</div>
</body>
</html>
</html>|
  end
end
