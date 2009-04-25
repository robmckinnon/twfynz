require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed bill debate with one subdebate plus two h2 headings" do
  include ParserHelperMethods

  before do
    @name = 'Hazardous Substances and New Organisms (Approvals and Enforcement) Amendment Bill'
    @sub_name = 'Second Reading'
    @class = BillDebate
    @css_class = 'billdebate'
    @publication_status = 'F'
    @bill_id = 111
    @date = Date.new(2005,12,13)

    @debate_index = 1
    @file_name = 'bill_debate_with_one_subdebate_plus_two_h2_headings.htm'
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

  it 'should create three sub-debates' do
    @debate.sub_debates.size.should == 3
  end

  it 'should set name correctly on each sub-debates' do
    @debate.sub_debates[0].name.should == 'Second Reading'
    @debate.sub_debates[1].name.should == 'In Committee'
    @debate.sub_debates[2].name.should == 'Third Reading'
  end

  it 'should create a section header contribution for h3 in "section" div' do
    @debate.sub_debates[1].contributions.first.should be_an_instance_of(SectionHeader)
    @debate.sub_debates[1].contributions.first.text.should == 'Part 1 Amendments to Parts 1, 4, 4A, 5, and 6 of principal Act'
  end

  it 'should set correct parent sub_debate on party vote' do
    @debate.sub_debates[2].contributions.last.should be_an_instance_of(VotePlaceholder)
    @debate.sub_debates[2].contributions.last.spoken_in_id.should == @debate.sub_debates[2].id
  end

  def html
%Q|<html>
<head>
<meta name="DC.Date" content="2005-12-13T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Hazardous Substances and New Organisms (Approvals and Enforcement) Amendment Bill — Second Reading, In Committee, Third Reading</h1>
    <a name="DocumentReference"></a>
    <p>[Volume:628;Page:817]</p>
    <div class="BillDebate">
      <a name="page_817"></a>
      <h2>Tuesday, 13 December 2005</h2>
      <p class="Urgency">(<em>continued on Wednesday, 14 December 2005</em>)</p>
      <h2>Hazardous Substances and New Organisms (Approvals and Enforcement) Amendment Bill</h2>
      <div class="SubDebate">
        <h3>Second Reading</h3>
      </div>
      <h2>In Committee</h2>
      <div class="section">
        <h3>Part 1 Amendments to Parts 1, 4, 4A, 5, and 6 of principal Act</h3>
      </div>
      <h2>Third Reading</h2>
      <div class="partyVote">
        <table class="table vote">
          <caption><p>A party vote was called for on the question,
<em>That the Hazardous Substances and New Organisms (Approvals and Enforcement) Amendment Bill be now read a third time.</em>
            </p></caption>
          <tbody><tr><td class="VoteCount">Ayes 111</td>
              <td class="VoteText">New Zealand Labour 50; New Zealand National 48; New Zealand First 7; United Future 3; ACT New Zealand 2; Progressive 1.</td></tr>
            <tr><td class="VoteCount">Noes 10</td>
              <td class="VoteText">Green Party 6; Māori Party 4.</td></tr></tbody>
          <tfoot><tr><td class="VoteResult" colspan="2">Bill read a third time.</td></tr></tfoot>
        </table>
      </div>
    </div>
  </div>
</div>
</body>
</html>|
  end
end
