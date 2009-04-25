require File.dirname(__FILE__) + '/hansard_parser_oral_answers_spec_helper'

describe HansardParser, " when passed 48HansD_20070814_00000157-Questions-for-Oral-Answer-Questions-to-Ministers.htm" do
  include OralAnswersHelperMethods

  before do
    @file_name = 'nil'
    @name = 'Questions to Ministers'
    @class = OralAnswers
    @debate_index = 1
    @date = Date.new(2007,8,14)
    @publication_status = 'F'
    @css_class = 'qoa'

    @ministers = [
        'Minister of Education',
        'Prime Minister',
        'Minister for Social Development and Employment',
        'Minister of Justice',
        'Minister of Finance',
        'Minister of Health',
        'Minister for the Environment',
        'Minister of State Services',
        'Minister of State Services',
        'Minister of Energy',
        'Minister of Housing',
        'Minister for Courts'
    ]

    HansardParser.stub!(:load_file).and_return html
    parse_oral_answers_all
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All debates"

  it 'should set volume number on oral answer debates' do
    @debate.hansard_volume.should == 640
  end

  it 'should set start page number on oral answer debates using the initial page number' do
    @debate.start_page.should == 11032
  end

  it 'should create correct number of child oral answer debates' do
    @debate.oral_answers.size.should == 5
  end

  it 'should set correct name on an oral answer debate' do
    @debate.oral_answers[0].name.should == 'Education—Competition'
  end

  it 'should set hansard volumn on an oral answer debate' do
    @debate.oral_answers[0].hansard_volume.should == 640
  end

  it 'should set correct number on an oral answer debate when number and speaker in same strong element' do
    @debate.oral_answers[0].oral_answer_no.should == 1
  end

  it 'should set speaker on a contribution when oral question no and speaker name are on different lines' do
    @debate.oral_answers[0].contributions.first.speaker.should == 'DIANNE YATES (Labour)'
  end

  it 'should set page number on a contribution using the initial page number' do
    @debate.oral_answers[0].contributions.first.page.should == 11032
  end

  it 'should set page number on a contribution using page number from previous a element' do
    @debate.oral_answers[0].contributions[3].page.should == 11033
  end

  it 'should set correct number on an oral answer debate when number and speaker in different strong elements' do
    @debate.oral_answers[1].oral_answer_no.should == 2
  end

  it 'should create a procedural contribution for an "ul" element contents' do
    @debate.oral_answers[1].contributions[3].should be_an_instance_of(Procedural)
    @debate.oral_answers[1].contributions[3].text.should == '<p>withdrew from the Chamber.</p>'
  end

  it 'should set debate about index to 1 for first question to a minister' do
    @debate.oral_answers[2].about_index.should == 1
  end

  it 'should set debate about index to 2 for second question to a minister' do
    @debate.oral_answers[3].about_index.should == 2
  end

  it 'should set time on contribution when time is present' do
    @debate.oral_answers[4].contributions[0].time.strftime('%H:%M:%S').should == '15:19:33'
  end

  it 'should create speech contribution when a contribution is a speech' do
    @debate.oral_answers[4].contributions[0].should be_an_instance_of(Speech)
  end

  it 'should append a paragraph with class "a" to text of previous contribution' do
    @debate.oral_answers[4].contributions[0].text.should == '<p>I</p>'+
        '<p>The</p>'+
        '<p>What</p>'
  end

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - Questions for Oral Answer — Questions to Ministers</title>
<meta name="DC.Date" content="2007-08-14T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Questions for Oral Answer — Questions to Ministers</h1>
    <a name="DocumentReference"></a>
    <p>[Volume:640;Page:11032]</p>
    <div class="QOA">
      <h2>Questions to Ministers</h2>
      <h4 class="QSubjectHeading">Education—Competition</h4>
      <div class="SubsQuestion">
        <p class="SubsQuestion">
          <strong>1. DIANNE YATES (Labour)</strong> to the <strong>Minister of Education</strong>: What </p>
        <p class="SubsAnswer">
          <a name="time_14:12:44"></a>
          <strong>Hon STEVE MAHAREY (Minister of Education)</strong> <strong>:</strong> I </p>
        <p class="Interjection">
          <strong>Madam SPEAKER</strong>: That </p>
        <a name="page_11033"></a>
        <p class="SupQuestion">
          <strong>Dianne Yates</strong>: What </p>
        <p class="SupAnswer">
          <strong>Hon STEVE MAHAREY</strong>: I </p>
      </div>
      <h4 class="QSubjectheadingalone">Electoral Finance Bill—Select Committee Changes</h4>
      <div class="SubsQuestion">
        <p class="SubsQuestion">
          <strong>2.</strong> <strong>JOHN KEY (Leader of the Opposition)</strong> to the <strong>Prime Minister</strong>: Does </p>
        <p class="SubsAnswer">
          <a name="time_14:20:15"></a>
          <strong>Rt Hon HELEN CLARK (Prime Minister)</strong><strong>:</strong> Yes</p>
        <p class="Intervention"><strong>Madam SPEAKER</strong>: please leave the House.</p>
        <ul class=""><li>withdrew from the Chamber.</li></ul>
      </div>
      <h4 class="QSubjectheadingalone">State Services Commissioner—Environment, Ministry</h4>
      <div class="SubsQuestion">
        <p class="SubsQuestion">
          <strong>3.</strong> <strong>GERRY BROWNLEE (National—Ilam)</strong> to the <strong>Minister of State Services</strong>: Did </p>
        <a name="page_11045"></a>
        <p class="SubsAnswer">
          <a name="time_15:05:44"></a>
          <strong>Hon ANNETTE KING (Minister of State Services)</strong>
          <strong>:</strong> The </p>
      </div>
      <h4 class="QSubjectheadingalone">Therapeutic Products and Medicines Bill—Deferment</h4>
      <div class="SubsQuestion">
        <p class="SubsQuestion">
          <strong>4. </strong>
          <strong>DARIEN FENTON (Labour)</strong> to the <strong>Minister of State Services</strong>: What </p>
        <p class="SubsAnswer">
          <a name="time_15:09:43"></a>
          <strong>Hon ANNETTE KING (Minister of State Services)</strong>
          <strong>:</strong> The </p>
        <a name="page_11046"></a>
        <p class="SupQuestion">
          <strong>Darien Fenton</strong>: Could </p>
        <a name="page_11047"></a>
      </div>
      <h4 class="QSubjectheadingalone">Question No. 10 to Minister</h4>
      <div class="Speech">
        <p class="Speech">
          <a name="time_15:19:33"></a>
          <strong>Hon Dr NICK SMITH (National—Nelson)</strong>
          <strong>:</strong> I </p>
        <p class="a">The </p>
        <p class="a">What </p>
      </div>
    </div>
  </div>
</div>
</body>
</html>|
  end
end
