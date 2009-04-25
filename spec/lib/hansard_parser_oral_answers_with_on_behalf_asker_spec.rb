require File.dirname(__FILE__) + '/hansard_parser_oral_answers_spec_helper'

describe HansardParser, " when passed oral answers with on behalf asker" do

  include OralAnswersHelperMethods

  before do
    @file_name = 'nil'
    @name = 'Questions to Ministers'
    @class = OralAnswers
    @debate_index = 1
    @date = Date.new(2005,11,16)
    @publication_status = 'F'
    @css_class = 'qoa'

    @ministers = [
        'Minister of Education',
        'Minister for the Environment',
        'Minister of Broadcasting',
        'Minister for Tertiary Education',
        'Minister of Foreign Affairs',
        'Minister of Health',
        'Minister of Police',
        'Minister of Education',
        'Minister of State Services',
        'Minister of Immigration',
        'Minister of Immigration',
        'Minister of Internal Affairs'
    ]

    HansardParser.stub!(:load_file).and_return html
    parse_oral_answers_all
  end

  it 'should create an oral answer debate for a "QSubjectheadingalone" h4 heading' do
    @debate.sub_debates[0].name.should == 'Milk in Refillable Glass Bottles—Packaging Accord and Waste Strategy'
  end

  it 'should create a question contribution with on behalf of set correctly' do
    @debate.sub_debates[0].contributions.first.should be_an_instance_of(SubsQuestion)
    @debate.sub_debates[0].contributions.first.on_behalf_of.should == 'JEANETTE FITZSIMONS (Co-Leader—Green)'
  end

  it 'should create a question contribution with speaker set correctly when on behalf of' do
    @debate.sub_debates[0].contributions.first.speaker.should == 'NANDOR TANCZOS (Green)'
  end

  it 'should create a question contribution with about_id set correctly when on behalf of' do
    @debate.sub_debates[0].about_id.should == 2
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  def html
    %Q|<html>
  <head>
    <title>New Zealand Parliament - Questions for Oral Answer — Questions to Ministers</title>
    <meta name="DC.Date" content="2005-11-16T12:00:00.000Z" />
  </head>
  <body>
    <div class="copy">
      <div class="section">
        <a name="DocumentTitle"></a>
        <h1>Questions for Oral Answer — Questions to Ministers</h1>
        <a name="DocumentReference"></a>
        <p>[Volume:628;Page:167]</p>
        <div class="QOA">
          <h2>Questions to Ministers</h2>
          <h4 class="QSubjectheadingalone">Milk in Refillable Glass Bottles—Packaging Accord and Waste Strategy</h4>
          <div class="SubsQuestion">
            <p class="SubsQuestion">
              <strong>1. </strong>
              <strong>NANDOR TANCZOS (Green)</strong>, on behalf of <strong>JEANETTE FITZSIMONS (Co-Leader—Green)</strong>, to the <strong>Minister for the Environment:</strong> Will </p>
            <a name="page_170"></a>
            <p class="SubsAnswer">
              <a name="time_14:17:28"></a>
              <strong>Hon DAVID BENSON-POPE (Minister for the Environment)</strong>
              <strong>:</strong> I </p>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>|
  end
end
