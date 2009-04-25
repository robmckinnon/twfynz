require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed debate containing vote without result text" do
  include ParserHelperMethods

  before do
    @name = 'Taxation (Annual Rates of Income Tax 2007-08) Bill'
    @sub_name = 'Third Readings'
    @class = BillDebate
    @css_class = 'billdebate'
    @publication_status = 'A'
    @bill_id = 111
    @date = Date.new(2007,12,12)

    @debate_index = 1
    @file_name = '48HansD_20071212_00000680-Taxation-Annual-Rates-of-Income-Tax-2007_no_vote_result.htm'
    def_parties
    HansardParser.stub!(:load_file).and_return html
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it 'should raise error about missing result text' do
    lambda { parse_debate }.should raise_error(Exception, /vote_result is blank/)
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
    <h1>Taxation (Annual Rates of Income Tax 2007-08) Bill, Taxation (Business Taxation and Remedial Matters) Bill, Taxation (KiwiSaver) Bill — Third Readings</h1>
    <a name="DocumentReference"></a>
    <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
    <div class="BillDebate">
      <h2>Taxation (Annual Rates of Income Tax 2007-08) Bill</h2>
      <div class="SubDebate">
        <h3>Third Reading</h3>
        <div class="partyVote">
          <table class="table vote">
            <caption>
              <p>A party vote was called for on the question,
<em>That the Taxation (Annual Rates of Income Tax 2007-08) Bill, the Taxation (Business Taxation and Remedial Matters) Bill, and the Taxation (KiwiSaver) Bill be now read a third time.</em>
              </p>
            </caption>
            <tbody>
              <tr>
                <td class="VoteCount">Ayes 65</td>
                <td class="VoteText">New Zealand Labour 49; New Zealand First 7; Māori Party 4; United Future 2; Progressive 1; Independents: Copeland, Field.</td>
              </tr>
              <tr>
                <td class="VoteCount">Noes 50</td>
                <td class="VoteText">New Zealand National 48; ACT New Zealand 2.</td>
              </tr>
              <tr>
                <td class="VoteCount">Abstentions 6</td>
                <td class="VoteText">Green Party 6.</td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
                <td class="VoteResult" colspan="2"></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>
</body>
</html>|
  end
end
