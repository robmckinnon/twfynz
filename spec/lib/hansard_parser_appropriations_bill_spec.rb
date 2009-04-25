require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed Appropriation (2007/08 Estimates) Bill—Third Reading, Imprest Supply Debate" do
  include ParserHelperMethods

  before do
    @name = 'Appropriation (2007/08 Estimates) Bill'
    @sub_name = 'Third Reading, Imprest Supply Debate'
    @class = BillDebate
    @css_class = 'billdebate'
    @publication_status = 'A'
    @bill_id = 111
    @date = Date.new(2007,8,14)

    @debate_index = 1
    @file_name = 'nil'

    def_parties
    HansardParser.stub!(:load_file).and_return html
    @debate = parse_debate
    @sub_debate = @debate.sub_debate
    @vote = @sub_debate.contributions.last.vote
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All parent debates"

  it 'should create a speech contribution for "Speech" paragraph and following "a" paragraphs' do
    @sub_debate.contributions.first.should_not be_nil
    @sub_debate.contributions.first.should be_an_instance_of(Speech)
  end

  it 'should create a interjection contribution for "Interjection" paragraph' do
    @sub_debate.contributions[1].should be_an_instance_of(Interjection)
  end

  it 'should create a continue speech contribution for "ContinueSpeech" paragraph' do
    @sub_debate.contributions[2].should be_an_instance_of(ContinueSpeech)
  end

  it 'should create correct number of paragraphs in text of continue speech contribution' do
    paragraphs = @sub_debate.contributions[2].text.split('<p>')
    paragraphs.delete("")
    paragraphs.size.should == 6
  end

  it 'should set time on a speech contribution, if time is present' do
    @sub_debate.contributions.first.time.strftime('%H:%M:%S').should == '15:37:40'
  end

  it 'should set speaker on a speech contribution' do
    @sub_debate.contributions.first.speaker.should == 'Hon Dr MICHAEL CULLEN (Minister of Finance)'
  end

  it 'should be about Bill' do
    @sub_debate.about_type.should == Bill.name
    @sub_debate.about_id.should == @bill_id
  end

  it 'should create a vote placeholder contribution for a "partyVote" div' do
    @sub_debate.contributions.last.should_not be_nil
    @sub_debate.contributions.last.should be_an_instance_of(VotePlaceholder)
    @sub_debate.contributions.last.debate.id.should == @sub_debate.id
    @sub_debate.contributions.last.text.should == 'A party vote was called for on the question,'
  end

  it 'should create a vote with vote question text for a vote table caption' do
    @vote.should be_an_instance_of(PartyVote)
    @vote.vote_question.should == 'That the Appropriation (2007/08 Estimates) Bill be now read a third time.'
  end

  it 'should create a vote with correct count of vote cast as ayes, noes, absentions' do
    @vote.ayes.size.should == 6
    @vote.noes.size.should == 2
    @vote.abstentions.size.should == 2
  end

  it 'should create a party vote with correct tally of ayes, noes, absentions' do
    @vote.ayes_tally.should == 61
    @vote.noes_tally.should == 50
    @vote.abstentions_tally.should == 9
  end

  # New Zealand Labour 49; New Zealand First 7; United Future 2; Progressive 1; Independents: Copeland, Field.
  it 'should create a party vote with correct ayes by party' do
    @vote.ayes[0].vote_label.should == @labour.vote_name
    @vote.ayes[1].vote_label.should == @nz_first.vote_name
    @vote.ayes[2].vote_label.should == @uf.vote_name
    @vote.ayes[3].vote_label.should == @progressive.vote_name
    @vote.ayes[4].vote_label.should == 'Copeland'
    @vote.ayes[5].vote_label.should == 'Field'
  end

  # New Zealand National 48; ACT New Zealand 2.
  it 'should create a party vote with correct noes by party' do
    @vote.noes[0].vote_label.should == @national.vote_name
    @vote.noes[1].vote_label.should == @act.vote_name
  end

  # # Green Party 6; Māori Party 3.
  it 'should create a party vote with correct abstentions by party' do
    @vote.abstentions[0].vote_label.should == @greens.vote_name
    @vote.abstentions[1].vote_label.should == @maori.vote_name
  end

  # New Zealand Labour 49; New Zealand First 7; United Future 2; Progressive 1; Independents: Copeland, Field.
  it 'should create a party vote with correct aye counts by party' do
    @vote.ayes[0].cast_count.should == 49
    @vote.ayes[1].cast_count.should == 7
    @vote.ayes[2].cast_count.should == 2
    @vote.ayes[3].cast_count.should == 1
    @vote.ayes[4].cast_count.should == 1
    @vote.ayes[5].cast_count.should == 1
  end

  # New Zealand National 48; ACT New Zealand 2.
  it 'should create a party vote with correct noe counts by party' do
    @vote.noes[0].cast_count.should == 48
    @vote.noes[1].cast_count.should == 2
  end

  # Green Party 6; Māori Party 3.
  it 'should create a party vote with correct abstention counts by party' do
    @vote.abstentions[0].cast_count.should == 6
    @vote.abstentions[1].cast_count.should == 3
  end

  def html
%Q|<html>
<head>
<title>New Zealand Parliament - Appropriation (2007/08 Estimates) Bill — Third Reading, Imprest Supply Debate</title>
<meta name="DC.Date" content="2007-08-14T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Appropriation (2007/08 Estimates) Bill — Third Reading, Imprest Supply Debate</h1>
    <a name="DocumentReference"></a>
    <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
    <div class="DebateDebate">
      <h2>Appropriation (2007/08 Estimates) Bill</h2>
      <div class="SubDebate">
        <h3>Third Reading, Imprest Supply Debate</h3>
        <div class="Speech">
          <p class="Speech"><a name="time_15:37:40"></a><strong>Hon Dr MICHAEL CULLEN (Minister of Finance)</strong><strong>:</strong> I move</p>
          <p class="Interjection"><strong>Hon Member</strong>: Oh, that’s really helpful.</p>
          <p class="ContinueSpeech"><strong>Hon Dr MICHAEL CULLEN</strong>: That</p>
          <p class="a">Mr </p>
          <p class="a">Then, </p>
          <p class="a">John </p>
          <a name="page_11054"></a>
          <p class="a">After </p>
          <p class="a">Let </p>
        </div>
        <div class="partyVote">
          <table class="table vote">
            <caption><p>A party vote was called for on the question,
<em>That the Appropriation (2007/08 Estimates) Bill be now read a third time.</em></p></caption>
            <tbody><tr><td class="VoteCount">Ayes 61</td>
                <td class="VoteText">New Zealand Labour 49; New Zealand First 7; United Future 2; Progressive 1; Independents: Copeland, Field.</td></tr>
              <tr><td class="VoteCount">Noes 50</td>
                <td class="VoteText">New Zealand National 48; ACT New Zealand 2.</td></tr>
              <tr><td class="VoteCount">Abstentions 9</td>
                <td class="VoteText">Green Party 6; Māori Party 3.</td></tr></tbody>
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

