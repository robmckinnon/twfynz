require File.dirname(__FILE__) + '/hansard_parser_oral_answers_spec_helper'

describe HansardParser, " when passed questions to ministers and members" do

  include OralAnswersHelperMethods

  before do
    @file_name = 'nil'
    @name = 'Questions to Ministers'
    @class = OralAnswers
    @debate_index = 1
    @date = Date.new(2006,8,3)
    @publication_status = 'F'
    @css_class = 'qoa'

    @ministers = [
        'Minister of Education',
        'Minister of Immigration',
        'Minister of Fisheries',
        'Minister of Immigration',
        'Minister for Social Development and Employment',
        'Minister of Labour',
        'Minister of Immigration',
        'Minister of Immigration',
        'Minister for Arts, Culture and Heritage',
        'Minister of Health',
        'Minister of Commerce',
        'Minister of Māori Affairs'
    ]

    bill = mock(Bill)
    bill.stub!(:id).and_return 33
    mp = mock(Mp)
    mp.stub!(:party).and_return nil
    mp.stub!(:id).and_return 23
    bill.stub!(:member_in_charge).and_return(mp)
    Bill.stub!(:from_name_and_date).and_return(bill)

    chair = mock(CommitteeChair)
    chair.stub!(:id).and_return 44
    committee = mock(Committee)
    committee.stub!(:id).and_return 55
    chair.stub!(:committee).and_return(committee)
    CommitteeChair.stub!(:from_name).and_return(chair)

    HansardParser.stub!(:load_file).and_return html
    debates = parse_oral_answers_all
    @debate = debates[0]
    @other_debate = debates[1]
  end

  it 'should create two oral_answers debates' do
    @debate.should be_an_instance_of(OralAnswers)
    @other_debate.should be_an_instance_of(OralAnswers)
  end

  it 'should create a questions to members oral_answers debate' do
    @other_debate.name.should == 'Questions to Members'
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All debates"

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - Questions for Oral Answer — Questions to Ministers, Questions to Members</title>
<meta name="DC.Date" content="2006-08-03T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Questions for Oral Answer — Questions to Ministers, Questions to Members</h1>
    <a name="DocumentReference"></a>
    <p>[Volume:633;Page:4688]</p>
    <div class="QOA">
      <h2>Questions to Ministers</h2>
      <h4 class="QSubjectHeading">Numeracy—Government Initiatives</h4>
      <div class="SubsQuestion">
        <p class="SubsQuestion">
          <strong>1. MOANA MACKEY (Labour)</strong> to the <strong>Minister of Education</strong>: What</p>
        <p class="SubsAnswer">
          <a name="time_14:04:13"></a>
          <strong>Hon STEVE MAHAREY (Minister of Education)</strong>
          <strong>:</strong> Last </p>
      </div>
      <h2>Questions to Members</h2>
      <h4 class="QSubjectHeading">Employment Relations (Probationary Employment) Amendment Bill—Purpose</h4>
      <div class="SubsQuestion">
        <p class="SubsQuestion">
          <strong>1.</strong>
          <strong>PAULA BENNETT (National)</strong> to the <strong>Member in charge of the Employment Relations (Probationary Employment) Amendment Bill</strong>: Who </p>
        <p class="SubsAnswer">
          <a name="time_15:19:17"></a>
          <strong>Dr WAYNE MAPP (</strong>
          <strong>Member in charge of the Employment Relations (Probationary Employment) Amendment Bill</strong>
          <strong>)</strong><strong>:</strong> The </p>
      </div>
    </div>
  </div>
</div>
</body>
</html>|
  end
end
