require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed Abortion Supervisory Committee Appointments debate" do
  include ParserHelperMethods

  before do
    @name = 'Appointments'
    @sub_name = 'Abortion Supervisory Committee'
    @class = ParentDebate
    @css_class = 'debate'
    @publication_status = 'F'
    @bill_id = nil
    @date = Date.new(2007,6,14)

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

  it 'should create a vote placeholder contribution for a "personalVote" div' do
    @sub_debate.contributions.last.should_not be_nil
    @sub_debate.contributions.last.should be_an_instance_of(VotePlaceholder)
    @sub_debate.contributions.last.debate.id.should == @sub_debate.id
  end

  it 'should set text on a vote placeholder contribution when vote question is in an em element' do
    @sub_debate.contributions.last.text.should == 'A personal vote was called for on the question,'
  end

  it 'should set text on a vote placeholder contribution when vote question is NOT in an em element' do
    index = @sub_debate.contributions.size - 2
    @sub_debate.contributions[index].text.should == 'A personal vote was called for on the question,'
  end

  it 'should create vote for personalVote div' do
    @vote.should_not be_nil
    @vote.should be_an_instance_of(PersonalVote)
  end

  it 'should set vote question on a vote when vote question is in an em element' do
    @vote.vote_question.should == 'That pursuant to sections 10 and 11 of the Contraception, Sterilisation, and Abortion Act 1977, this House recommend His Excellency the Governor-General appoint Professor Linda Jane Holloway DCNZM of Dunedin, Dr Rosemary Jane Fenwicke of Wellington, and Patricia Ann Allan of Christchurch, as members of the Abortion Supervisory Committee, and appoint Professor Linda Jane Holloway as Chairman of the Supervisory Committee.'
  end

  it 'should set vote question on a vote when vote question is NOT in an em element' do
    index = @sub_debate.contributions.size - 2
    vote = @sub_debate.contributions[index].vote
    vote.vote_question.should == 'That the motion be amended by omitting the words “Patricia Ann Allan of Christchurch”, and substituting the words “Dr Peter Hall of Whangaparāoa”'
  end

  it 'should create a vote with vote result text' do
    @vote.vote_result.should == 'Motion agreed to.'
  end

  it 'should create a personal vote with correct tally of ayes, noes, absentions' do
    @vote.ayes_tally.should == 102
    @vote.noes_tally.should == 11
    @vote.abstentions_tally.should == 5
  end

  it 'should create a vote with correct count of votes cast as ayes, noes, absentions' do
    @vote.ayes.size.should == 102
    @vote.noes.size.should == 11
    @vote.abstentions.size.should == 5
  end

  it 'should set last ayes vote cast to be a teller for personalVote' do
    @vote.ayes.last.teller.should be_true
  end

  it 'should set last noes vote cast to be a teller for personalVote' do
    @vote.noes.last.teller.should be_true
  end

  it 'should not set last abstentions vote cast to be a teller for personalVote' do
    @vote.abstentions.last.teller.should be_false
  end

  it 'should set cast count to 1 for each personal vote cast' do
    @vote.vote_casts.each {|cast| cast.cast_count.should == 1}
  end

  it 'should set vote_label correctly on a vote cast' do
    @vote.vote_casts.first.vote_label.should == 'Ardern(P)'
  end

  it 'should leave "(P)" text in a vote cast vote_label, if "(P)" is present' do
    @vote.vote_casts.first.vote_label.include?("(P)").should be_true
  end

  it 'should set vote cast present to true if vote label contains "(p)"' do
    @vote.vote_casts.first.present.should be_true
  end

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - Appointments — Abortion Supervisory Committee</title>
<meta name="DC.Date" content="2007-06-14T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a><h1>Appointments — Abortion Supervisory Committee</h1>
    <a name="DocumentReference"></a><p>[Volume:639;Page:9906]</p>
    <div class="Debate">
      <h2>Appointments</h2>
      <div class="SubDebate">
        <h3>Abortion Supervisory Committee</h3>
        <div class="Speech">
          <p class="Speech">
            <strong>Hon MARK BURTON (Minister of Justice)</strong>
            <strong>:</strong> I move,</p></div>
        <div class="personalVote">A personal vote was called for on the question,
 <em>That the motion be amended by omitting the words “Dr Rosemary Jane Fenwicke of Wellington”, and substituting the words “Dr Ate Moala of Wellington”.
 </em><table class="table vote"><caption>Ayes 36</caption><colgroup></colgroup><tbody><tr><td>Ardern(P)</td><td>Copeland</td><td>Mapp(P)</td><td>Turia(P)</td></tr><tr><td>Bennett P</td><td>English</td><td>Mark(P)</td><td>Turner(P)</td></tr><tr><td>Blumsky(P)</td><td>Finlayson(P)</td><td>Peachey(P)</td><td></td></tr><tr><td>Borrows(P)</td><td>Flavell(P)</td><td>Peters(P)</td><td></td></tr><tr><td>Brown
 </td><td>Goodhew(P)</td><td>Power(P)</td><td></td></tr><tr><td>Brownlee(P)</td><td>Groser(P)</td><td>Roy E (P)</td><td></td></tr><tr><td>Carter D (P)</td><td>Guy</td><td>Ryall(P)</td><td></td></tr><tr><td>Carter J</td><td>Harawira</td><td>Simich</td><td></td></tr><tr><td>Clarkson(P)</td><td>Hayes</td><td>Smith N (P)</td><td></td></tr><tr><td>Collins(P)</td><td>Heatley(P)</td><td>Stewart(P)</td><td>Teller:</td></tr><tr><td>Connell(P)</td><td>Henare</td><td>te Heuheu(P)</td><td>Tolley
 </td></tr></tbody></table><table class="table vote"><caption>Noes
 81</caption><colgroup></colgroup><tbody><tr><td>Auchinvole(P)</td><td>Fenton(P)</td><td>Locke(P)</td><td>Swain(P)</td></tr><tr><td>Barker(P)</td><td>Fitzsimons(P)</td><td>Mackey(P)</td><td>Tanczos(P)</td></tr><tr><td>Bennett D (P)</td><td>Foss(P)</td><td>Maharey(P)</td><td>Tisch(P)</td></tr><tr><td>Benson-Pope(P)</td><td>Gallagher
  </td><td>Mahuta(P)</td><td>Tizard(P)</td></tr><tr><td>Blue
 </td><td>Goff(P)</td><td>Mallard(P)</td><td>Tremain(P)</td></tr><tr><td>Bradford(P)</td><td>Gosche(P)</td><td>McCully(P)</td><td>Turei(P)</td></tr><tr><td>Burton
 </td><td>Goudie(P)</td><td>Moroney(P)</td><td>Wagner
 </td></tr><tr><td>Carter C (P)</td><td>Hartley(P)</td><td>O’Connor(P)</td><td>Wilkinson
  </td></tr><tr><td>Chadwick(P)</td><td>Hawkins(P)</td><td>Okeroa
 </td><td>Williamson
  </td></tr><tr><td>Chauvel
 </td><td>Hereora(P)</td><td>Paraone(P)</td><td>Wilson(P)</td></tr><tr><td>Choudhary(P)</td><td>Hide(P)</td><td>Parker(P)</td><td>Wong(P)</td></tr><tr><td>Clark(P)</td><td>Hobbs(P)</td><td>Pettis(P)</td><td>Woolerton(P)</td></tr><tr><td>Coleman(P)</td><td>Hodgson(P)</td><td>Pillay
 </td><td>Worth(P)</td></tr><tr><td>Cosgrove
  </td><td>Horomia
 </td><td>Rich(P)</td><td>Yates (P)</td></tr><tr><td>Cullen
 </td><td>Hughes
 </td><td>Ririnui(P)</td><td></td></tr><tr><td>Cunliffe(P)</td><td>Hutchison(P)</td><td>Robertson(P)</td><td></td></tr><tr><td>Dalziel(P)</td><td>Jones(P)</td><td>Roy H
 </td><td></td></tr><tr><td>Donnelly(P)</td><td>Kedgley
 </td><td>Samuels(P)</td><td></td></tr><tr><td>Dunne(P)</td><td>Key(P)</td><td>Shanks
 </td><td></td></tr><tr><td>Duynhoven
  </td><td>King A</td><td>Smith L (P)</td><td></td></tr><tr><td>Dyson(P)</td><td>King C (P)</td><td>Soper
 </td><td>Teller:</td></tr><tr><td>Fairbrother(P)</td><td>Laban(P)</td><td>Street(P)</td><td>Barnett
 </td></tr></tbody></table><p class="VoteResult">Amendment not agreed to.</p></div>
        <div class="personalVote">A personal vote was called for on the question,
 That the motion be amended by omitting the words “Patricia Ann Allan of Christchurch”, and substituting the words “Dr Peter Hall of Whangaparāoa”<table class="table vote"><caption>Ayes
 29</caption><colgroup></colgroup><tbody><tr><td>Bennett P(P)</td><td>Foss(P)</td><td>Peters(P)</td><td>Wagner(P)</td></tr><tr><td>Borrows(P)</td><td>Goodhew(P)</td><td>Roy E(P)</td><td>Wong(P)</td></tr><tr><td>Carter J</td><td>Guy</td><td>Ryall(P)</td><td>Woolerton(P)</td></tr><tr><td>Collins(P)</td><td>Heatley(P)</td><td>Smith L</td><td>Worth(P)</td></tr><tr><td>Copeland</td><td>Key(P)</td><td>Smith N(P)</td><td></td></tr><tr><td>Donnelly(P)</td><td>Mapp(P)</td><td>Stewart(P)</td><td></td></tr><tr><td>English</td><td>Mark(P)</td><td>te Heuheu(P)</td><td>Teller</td></tr><tr><td>Finlayson(P)</td><td>Paraone(P)</td><td>Tremain(P)</td><td>Brown</td></tr></tbody></table><table class="table vote"><caption>Noes
 76</caption><colgroup></colgroup><tbody><tr><td>Auchinvole(P)</td><td>Fairbrother(P)</td><td>King A</td><td>Simich</td></tr><tr><td>Barker(P)</td><td>Fenton(P)</td><td>Laban(P)</td><td>Soper
 </td></tr><tr><td>Benson-Pope(P)</td><td>Fitzsimons(P)</td><td>Locke(P)</td><td>Street(P)</td></tr><tr><td>Blue
  </td><td>Flavell(P)</td><td>Mackey(P)</td><td>Swain(P)</td></tr><tr><td>Blumsky(P)</td><td>Gallagher
  </td><td>Maharey(P)</td><td>Tanczos(P)</td></tr><tr><td>Bradford(P)</td><td>Goff(P)</td><td>Mahuta(P)</td><td>Tisch(P)</td></tr><tr><td>Burton
  </td><td>Gosche(P)</td><td>Mallard(P)</td><td>Tizard(P)</td></tr><tr><td>Carter C (P)</td><td>Harawira
  </td><td>Moroney(P)</td><td>Tolley(P)</td></tr><tr><td>Chadwick(P)</td><td>Hartley(P)</td><td>O’Connor(P)</td><td>Turei(P)</td></tr><tr><td>Chauvel
  </td><td>Hawkins(P)</td><td>Okeroa
 </td><td>Turia(P)</td></tr><tr><td>Choudhary(P)</td><td>Hayes
 </td><td>Parker(P)</td><td>Turner(P)</td></tr><tr><td>Clark(P)</td><td>Henare
 </td><td>Peachey(P)</td><td>Wilkinson
  </td></tr><tr><td>Clarkson(P)</td><td>Hereora(P)</td><td>Pettis(P)</td><td>Williamson
  </td></tr><tr><td>Cosgrove
  </td><td>Hide(P)</td><td>Pillay
 </td><td>Wilson(P)</td></tr><tr><td>Cullen
  </td><td>Hobbs(P)</td><td>Power(P)</td><td>Yates (P)</td></tr><tr><td>Cunliffe(P)</td><td>Hodgson(P)</td><td>Ririnui(P)</td><td></td></tr><tr><td>Dalziel(P)</td><td>Horomia
 </td><td>Robertson(P)</td><td></td></tr><tr><td>Dunne(P)</td><td>Hughes
 </td><td>Roy H</td><td></td></tr><tr><td>Duynhoven
  </td><td>Jones
 </td><td>Samuels
 </td><td>Teller:</td></tr><tr><td>Dyson(P)</td><td>Kedgley
 </td><td>Shanks
 </td><td>Barnett
 </td></tr></tbody></table><p class="VoteResult">Amendment not agreed to.</p></div>
        <div class="personalVote">A personal vote was called for on the question,
 <em>That pursuant to sections 10 and 11 of the Contraception, Sterilisation, and Abortion Act 1977, this House recommend His Excellency the Governor-General appoint Professor Linda Jane Holloway DCNZM of Dunedin, Dr Rosemary Jane Fenwicke of Wellington, and Patricia Ann Allan of Christchurch, as members of the Abortion Supervisory Committee, and appoint Professor Linda Jane Holloway as Chairman of the Supervisory Committee.</em><table class="table vote"><caption>Ayes
 102</caption><colgroup></colgroup><tbody><tr><td>Ardern(P)</td><td>Fairbrother(P)</td><td>King A</td><td>Smith N (P)</td></tr><tr><td>Auchinvole(P)</td><td>Fenton(P)</td><td>King C</td><td>Soper</td></tr><tr><td>Barker(P)</td><td>Fitzsimons(P)</td><td>Laban(P)</td><td>Street(P)</td></tr><tr><td>Bennett D (P)</td><td>Flavell(P)</td><td>Locke(P)</td><td>Swain (P)</td></tr><tr><td>Bennett P (P)</td><td>Foss(P)</td><td>Mackey(P)</td><td>Tanczos(P)</td></tr><tr><td>Benson-Pope(P)</td><td>Gallagher</td><td>Maharey(P)</td><td>te Heuheu(P)</td></tr><tr><td>Blue(P)</td><td>Goff(P)</td><td>Mahuta(P)</td><td>Tisch(P)</td></tr><tr><td>Blumsky(P)</td><td>Goodhew(P)</td><td>Mallard(P)</td><td>Tizard(P)</td></tr><tr><td>Borrows(P)</td><td>Gosche(P)</td><td>Mapp(P)</td><td>Tolley(P)</td></tr><tr><td>Bradford(P)</td><td>Goudie(P)</td><td>McCully(P)</td><td>Tremain(P)</td></tr><tr><td>Burton</td><td>Groser(P)</td><td>Moroney(P)</td><td>Turei(P)</td></tr><tr><td>Carter C (P)</td><td>Guy</td><td>O’Connor(P)</td><td>Turia(P)</td></tr><tr><td>Carter D (P)</td><td>Harawira</td><td>Okeroa</td><td>Turner(P)</td></tr><tr><td>Chadwick</td><td>Hartley(P)</td><td>Parker(P)</td><td>Wagner(P)</td></tr><tr><td>Chauvel</td><td>Hawkins(P)</td><td>Peachey(P)</td><td>Wilkinson</td></tr><tr><td>Choudhary(P)</td><td>Hayes(P)</td><td>Pettis(P)</td><td>Williamson</td></tr><tr><td>Clark(P)</td><td>Henare</td><td>Pillay</td><td>Wilson(P)</td></tr><tr><td>Clarkson(P)</td><td>Hereora(P)</td><td>Power(P)</td><td>Wong(P)</td></tr><tr><td>Coleman(P)</td><td>Hide(P)</td><td>Rich(P)</td><td>Worth(P)</td></tr><tr><td>Connell(P)</td><td>Hobbs(P)</td><td>Ririnui(P)</td><td>Yates (P)</td></tr><tr><td>Cosgrove</td><td>Hodgson(P)</td><td>Robertson(P)</td><td></td></tr><tr><td>Cullen</td><td>Horomia</td><td>Roy H</td><td></td></tr><tr><td>Cunliffe(P)</td><td>Hughes</td><td>Ryall(P)</td><td></td></tr><tr><td>Dalziel(P)</td><td>Hutchison(P)</td><td>Samuels</td><td></td></tr><tr><td>Dunne(P)</td><td>Jones</td><td>Shanks</td><td></td></tr><tr><td>Duynhoven</td><td>Kedgley</td><td>Simich</td><td>Teller:</td></tr><tr><td>Dyson(P)</td><td>Key(P)</td><td>Smith L (P)</td><td>Barnett</td></tr></tbody></table><table class="table vote"><caption>Noes
 11</caption><colgroup></colgroup><tbody><tr><td>Brown</td><td>English</td><td>Peters(P)</td><td></td></tr><tr><td>Brownlee(P)</td><td>Finlayson</td><td>Roy E (P)</td><td></td></tr><tr><td>Carter J</td><td>Heatley(P)</td><td></td><td>Teller:</td></tr><tr><td>Copeland</td><td>Mark(P)</td><td></td><td>Collins</td></tr></tbody></table><table class="table vote"><caption>Abstentions
 5</caption><colgroup></colgroup><tbody><tr><td>Dean(P)</td><td>Donnelly(P)</td><td>Paraone(P)</td><td>Stewart(P)</td></tr><tr><td>Woolerton(P)</td><td></td><td></td><td></td></tr></tbody></table><p class="VoteResult">Motion agreed to.</p></div>
      </div>
    </div>
  </div>
</div>
</body>
</html>|
  end
end
