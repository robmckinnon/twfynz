require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed Criminal Justice Reform Bill—In Committee" do
  include ParserHelperMethods

  before do
    @name = 'Criminal Justice Reform Bill'
    @sub_name = 'In Committee'
    @class = BillDebate
    @css_class = 'billdebate'
    @publication_status = 'A'
    @bill_id = 111
    @date = Date.new(2007,7,19)

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

  it 'should be about Bill' do
    @sub_debate.about_type.should == 'Bill'
    @sub_debate.about_id.should == @bill_id
  end

  it 'should create a procedural contribution for ul under SubDebate div' do
    contribution = @sub_debate.contributions.first
    contribution.should_not be_nil
    contribution.should be_an_instance_of(Procedural)
    contribution.text.should == '<p>Debate resumed from 18 July.</p>'
  end

  it 'should create a section header for "section" div h4' do
    contribution = @sub_debate.contributions[1]
    contribution.should_not be_nil
    contribution.should be_an_instance_of(SectionHeader)
    contribution.text.should == 'Part 2 Amendments to Acts relating to Criminal Justice (continued)'
  end

  it 'should create a speech contribution for "Speech" paragraph and following "a" paragraphs' do
    contribution = @sub_debate.contributions[2]
    contribution.should_not be_nil
    contribution.should be_an_instance_of(Speech)
    contribution.text.should == '<p>I</p>'+
          '<p>This</p>'+
          '<p>I</p>'+
          '<p>I</p>'+
          '<p>I</p>'
  end

  it 'should set speaker on a speech contribution' do
    @sub_debate.contributions[2].speaker.should == 'Dr WAYNE MAPP (National—North Shore)'
  end

  it 'should do create a clause description contribution for "Clause-Description0" paragraph' do
    @sub_debate.contributions[4].text.should == '<p>to omit subclause (3) of clause 96;</p>'
    @sub_debate.contributions[4].should be_an_instance_of(ClauseDescription)
  end

  it 'should do create a procedural contribution for each li in a ul element' do
    @sub_debate.contributions[10].text.should == '<p>Amendments agreed to.</p>'
    @sub_debate.contributions[10].should be_an_instance_of(Procedural)

    @sub_debate.contributions[11].text.should == '<p>The question was put that the amendments set out on Supplementary Order Paper 127 and 122 in the name of the Hon Mark Burton to Part 2 be agreed to.</p>'
    @sub_debate.contributions[11].should be_an_instance_of(Procedural)
  end

  def html
%Q|<html>
<head>
<title>New Zealand Parliament - Criminal Justice Reform Bill — In Committee</title>
<meta name="DC.Date" content="2007-07-19T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Criminal Justice Reform Bill — In Committee</h1>
    <a name="DocumentReference"></a>
    <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
    <div class="BillDebate">
      <h2>Criminal Justice Reform Bill</h2>
      <div class="SubDebate">
        <h3>In Committee</h3>
        <ul class="">
          <li>Debate resumed from 18 July.</li>
        </ul>
        <div class="section">
          <h4>Part 2 Amendments to Acts relating to Criminal Justice (continued)</h4>
        </div>
        <div class="Speech">
          <p class="Speech">
            <a name="time_15:23:55"></a>
            <strong>Dr WAYNE MAPP (National—North Shore)</strong>
            <strong>:</strong> I </p>
          <p class="a">This </p>
          <p class="a">I </p>
          <p class="a">I </p>
          <a name="page_10559"></a>
          <p class="a">I </p>
          <ul class="">
            <li>The question was put that the following amendments in the name of Heather Roy to Part 2 be agreed to:</li>
          </ul>
          <p class="Clause-Description0">to omit subclause (3) of clause 96;</p>
          <p class="Clause-Description0">to omit subclause (1) of clause 97;</p>
          <p class="Clause-Description0">to omit subparagraphs (ii) and (iii) from new section 45(7)(b) in clause 98;</p>
          <p class="Clause-Description0">to omit clause 101;</p>
          <p class="Clause-Description0">to omit clause 102; and</p>
          <p class="Clause-Description0">to omit clause 104</p>
          <ul class="">
            <li>Amendments agreed to.</li>
            <li>The question was put that the amendments set out on Supplementary Order Paper 127 and 122 in the name of the Hon Mark Burton to Part 2 be agreed to.</li>
          </ul>
          <a name="page_10570"></a>
        </div>
      </div>
    </div>
  </div>
</div>
</body>
</html>|
  end
end
