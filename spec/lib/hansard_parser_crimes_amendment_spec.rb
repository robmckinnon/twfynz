require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed Crimes (Substituted Section 59) Amendment Bill, Third Reading" do
  include ParserHelperMethods

  before do
    @name = 'Crimes (Substituted Section 59) Amendment Bill'
    @sub_name = 'Third Reading'
    @class = BillDebate
    @css_class = 'billdebate'
    @publication_status = 'F'
    @bill_id = 111
    @date = Date.new(2007,5,16)

    @debate_index = 1
    @file_name = 'nil'

    def_parties
    HansardParser.stub!(:load_file).and_return html
    @debate = parse_debate
    @sub_debate = @debate.sub_debate
    count = @sub_debate.contributions.size
    @vote = @sub_debate.contributions[0].vote
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All parent debates"

  it 'should create a party vote with vote question text for a vote table caption' do
    @vote.should be_an_instance_of(PartyVote)
    @vote.vote_question.should == 'That the Crimes (Substituted Section 59) Amendment Bill be now read a third time.'
  end

  it 'should create a party vote with correct tally of ayes, noes, absentions' do
    @vote.valid?.should be_true
    @vote.ayes_tally.should == 113
    @vote.noes_tally.should == 8
    @vote.abstentions_tally.should == 0
  end

  it 'should create a party vote with correct count of vote cast as ayes, when parties have split their votes' do
    @vote.ayes.size.should == 10
  end

  it 'should create a party vote with correct count of vote cast as noes, when parties have split their votes' do
    @vote.noes.size.should == 7
  end

  it 'should create a party vote with correct count of vote cast as absentions, when there are no abstentions' do
    @vote.abstentions.size.should == 0
  end

  # New Zealand Labour 49; New Zealand National 48;
  # New Zealand First 4 (Brown, Donnelly, Stewart, Woolerton);
  # Green Party 6; Māori Party 4; United Future 1 (Dunne); Progressive 1.
  it 'should create a party vote with correct aye counts by party' do
    ayes = @vote.ayes
    ayes[0].cast_count.should == 49
    ayes[1].cast_count.should == 48
    ayes[2].cast_count.should == 1
    ayes[3].cast_count.should == 1
    ayes[4].cast_count.should == 1
    ayes[5].cast_count.should == 1
    ayes[6].cast_count.should == 6
    ayes[7].cast_count.should == 4
    ayes[8].cast_count.should == 1
    ayes[9].cast_count.should == 1
  end

  # New Zealand Labour 49; New Zealand National 48;
  # New Zealand First 4 (Brown, Donnelly, Stewart, Woolerton);
  # Green Party 6; Māori Party 4; United Future 1 (Dunne); Progressive 1.
  it 'should create a party vote with correct ayes vote_labels' do
    ayes = @vote.ayes
    ayes[0].vote_label.should == @labour.vote_name
    ayes[1].vote_label.should == @national.vote_name
    ayes[2].vote_label.should == 'Brown'
    ayes[3].vote_label.should == 'Donnelly'
    ayes[4].vote_label.should == 'Stewart'
    ayes[5].vote_label.should == 'Woolerton'
    ayes[6].vote_label.should == @greens.vote_name
    ayes[7].vote_label.should == @maori.vote_name
    ayes[8].vote_label.should == 'Dunne'
    ayes[9].vote_label.should == @progressive.vote_name
  end

  # New Zealand Labour 49; New Zealand National 48;
  # New Zealand First 4 (Brown, Donnelly, Stewart, Woolerton);
  # Green Party 6; Māori Party 4; United Future 1 (Dunne); Progressive 1.
  it 'should create a party vote with correct party ids on ayes vote casts' do
    ayes = @vote.ayes
    ayes[0].party_id.should == @labour.id
    ayes[1].party_id.should == @national.id
    ayes[2].party_id.should == @nz_first.id
    ayes[3].party_id.should == @nz_first.id
    ayes[4].party_id.should == @nz_first.id
    ayes[5].party_id.should == @nz_first.id
    ayes[6].party_id.should == @greens.id
    ayes[7].party_id.should == @maori.id
    ayes[8].party_id.should == @uf.id
    ayes[9].party_id.should == @progressive.id
  end

  # New Zealand First 3 (Mark, Paraone, Peters); United Future 1 (Turner);
  # ACT New Zealand 2; Independents: Copeland, Field.
  it 'should create a party vote with correct noe counts by party' do
    noes = @vote.noes
    noes[0].cast_count.should == 1
    noes[1].cast_count.should == 1
    noes[2].cast_count.should == 1
    noes[3].cast_count.should == 1
    noes[4].cast_count.should == 2
    noes[5].cast_count.should == 1
    noes[6].cast_count.should == 1
  end

  # New Zealand First 3 (Mark, Paraone, Peters); United Future 1 (Turner);
  # ACT New Zealand 2; Independents: Copeland, Field.
  it 'should create a party vote with correct noes vote_labels' do
    noes = @vote.noes
    noes[0].vote_label.should == 'Mark'
    noes[1].vote_label.should == 'Paraone'
    noes[2].vote_label.should == 'Peters'
    noes[3].vote_label.should == 'Turner'
    noes[4].vote_label.should == @act.vote_name
    noes[5].vote_label.should == 'Copeland'
    noes[6].vote_label.should == 'Field'
  end

  # New Zealand First 3 (Mark, Paraone, Peters); United Future 1 (Turner);
  # ACT New Zealand 2; Independents: Copeland, Field.
  it 'should create a party vote with correct party ids on noes vote casts' do
    noes = @vote.noes
    noes[0].party_id.should == @nz_first.id
    noes[1].party_id.should == @nz_first.id
    noes[2].party_id.should == @nz_first.id
    noes[3].party_id.should == @uf.id
    noes[4].party_id.should == @act.id
    noes[5].party_id.should == @independent.id
    noes[6].party_id.should == @independent.id
  end

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - Crimes (Substituted Section 59) Amendment Bill — Third Reading</title>
<meta name="DC.Date" content="2007-05-16T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Crimes (Substituted Section 59) Amendment Bill — Third Reading</h1>
    <a name="DocumentReference"></a>
    <p>[Volume:639;Page:9284]</p>
    <div class="BillDebate">
      <h2>Crimes (Substituted Section 59) Amendment Bill</h2>
      <div class="SubDebate">
        <h3>Third Reading</h3>
        <div class="partyVote">
          <table class="table vote">
            <caption><p>A party vote was called for on the question, <em>That the Crimes (Substituted Section 59) Amendment Bill be now read a third time.</em></p></caption>
            <tbody><tr><td class="VoteCount">Ayes 113</td>
                <td class="VoteText">New Zealand Labour 49; New Zealand National 48; New Zealand First 4 (Brown, Donnelly, Stewart, Woolerton); Green Party 6; Māori Party 4; United Future 1 (Dunne); Progressive 1.</td>
              </tr>
              <tr><td class="VoteCount">Noes 8</td>
                <td class="VoteText">New Zealand First 3 (Mark, Paraone, Peters); United Future 1 (Turner); ACT New Zealand 2; Independents: Copeland, Field.</td>
              </tr></tbody>
            <tfoot><tr><td class="VoteResult" colspan="2">Bill read a third time.</td></tr></tfoot>
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
