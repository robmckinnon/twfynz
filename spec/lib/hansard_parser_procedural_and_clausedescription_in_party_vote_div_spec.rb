require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed bill debate with a procedural paragraph and a clause description in the partyvote div" do
  include ParserHelperMethods

  before do
    @name = 'Aviation Security Legislation Bill'
    @sub_name = 'In Committee'
    @class = BillDebate
    @css_class = 'billdebate'
    @publication_status = 'F'
    @bill_id = 111
    @date = Date.new(2007,9,11)

    @debate_index = 1
    @file_name = '48HansD_20070911_00001084-Aviation-Security-Legislation-Bill-In-Committee.htm'
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

  it 'should make a section header for an h4 element' do
    section_header = @sub_debate.contributions.first
    section_header.should be_an_instance_of(SectionHeader)
    section_header.text.should == 'Part 1 Amendments to Aviation Crimes Act 1972'
  end

  it 'should make a procedural contributon for ul li element in a "Speech" div' do
    contribution = @sub_debate.contributions[1]
    contribution.should be_an_instance_of(Procedural)
    contribution.text.should == '<p>The question was put that the following amendment in the name of Keith Locke to clause 17 be agreed to:</p>'
  end

  it 'should make a ClauseDescription for a "Clause-Description0" paragraph in a "Speech" div' do
    contribution = @sub_debate.contributions[2]
    contribution.should be_an_instance_of(ClauseDescription)
    contribution.text.should == '<p>to omit subclause (1) of section 77D.</p>'
  end

  it 'should make a VotePlaceholder for a "table vote" table in a "partyVote" div' do
    contribution = @sub_debate.contributions[3]
    contribution.should be_an_instance_of(VotePlaceholder)
  end

  it 'should make a procedural contributon for ul li element in a "partyVote" div' do
    contribution = @sub_debate.contributions[4]
    contribution.should be_an_instance_of(Procedural)
    contribution.text.should == '<p>The question was put that the following amendment in the name of Keith Locke to clause 17 be agreed to:</p>'
  end

  it 'should make a ClauseDescription for a "Clause-Description0" paragraph in a "partyVote" div' do
    contribution = @sub_debate.contributions[5]
    contribution.should be_an_instance_of(ClauseDescription)
    contribution.text.should == '<p>to omit from subclause (1) section 77E.</p>'
  end

  def html
    %Q+<html>
<head>
<title>New Zealand Parliament - Aviation Security Legislation Bill — In Committee</title>
<meta name="DC.Date" content="2007-09-11T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Aviation Security Legislation Bill — In Committee</h1>
    <a name="DocumentReference"></a>
    <p>[Volume:642;Page:11744]</p>
    <div class="BillDebate">
      <h2>Aviation Security Legislation Bill</h2>
      <div class="SubDebate">
        <h3>In Committee</h3>
        <div class="section">
          <h4>Part 1 Amendments to Aviation Crimes Act 1972</h4>
        </div>
        <div class="Speech">
          <ul class="">
            <li>The question was put that the following amendment in the name of Keith Locke to clause 17 be agreed to:</li>
          </ul>
          <p class="Clause-Description0">to omit subclause (1) of section 77D.</p>
        </div>
        <div class="partyVote">
          <table class="table vote">
            <caption>
              <p>A party vote was called for on the question,
<em>That the amendment be agreed to.</em>
              </p>
            </caption>
            <colgroup>
              <col width="" />
              <col width="" />
            </colgroup>
            <tbody>
              <tr>
                <td class="VoteCount">Ayes 6</td>
                <td class="VoteText">Green Party 6.</td>
              </tr>
              <tr>
                <td class="VoteCount">Noes 113</td>
                <td class="VoteText">New Zealand Labour 49; New Zealand National 48; New Zealand First 7; Māori Party 4; United Future 2; Progressive 1; Independents: Copeland, Field.</td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
                <td class="VoteResult" colspan="2">Amendment not agreed to.</td>
              </tr>
            </tfoot>
          </table>
          <ul class="">
            <li>The question was put that the following amendment in the name of Keith Locke to clause 17 be agreed to:</li>
          </ul>
          <p class="Clause-Description0">to omit from subclause (1) section 77E.</p>
        </div>
        <div class="partyVote">
          <table class="table vote">
            <caption>
              <p>A party vote was called for on the question,
<em>That the amendment be agreed to.</em>
              </p>
            </caption>
            <colgroup>
              <col width="" />
              <col width="" />
            </colgroup>
            <tbody>
              <tr>
                <td class="VoteCount">Ayes 6</td>
                <td class="VoteText">Green Party 6.</td>
              </tr>
              <tr>
                <td class="VoteCount">Noes 113</td>
                <td class="VoteText">New Zealand Labour 49; New Zealand National 48; New Zealand First 7; Māori Party 4; United Future 2; Progressive 1; Independents: Copeland, Field.</td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
                <td class="VoteResult" colspan="2">Amendment not agreed to.</td>
              </tr>
            </tfoot>
          </table>
        </div>
        <div class="section">
          <h4>Clause 1 agreed to. </h4>
        </div>
        <div class="section">
          <h4>Clause 2 agreed to. </h4>
        </div>
        <ul class="">
          <li>The Committee divided the bill into the Aviation Crimes Amendment Bill and the Civil Aviation Amendment Bill (No 2), <em>divided into Aviation Crimes Amendment Bill| Civil Aviation Amendment Bill (No 2)</em> pursuant to Supplementary Order Paper144.</li>
        </ul>
        <ul class="">
          <li>Bill reported with amendment.</li>
        </ul>
        <ul class="">
          <li>Report adopted.</li>
        </ul>
      </div>
    </div>
  </div>
</div>
</body>
</html>+
  end
end
