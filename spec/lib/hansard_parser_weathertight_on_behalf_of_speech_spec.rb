require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed bill debate with on behalf of speech" do
  include ParserHelperMethods

  before do
    @name = 'Weathertight Homes Resolution Services (Remedies) Amendment Bill, Building (Consent Authorities) Amendment Bill'
    @first_bill_name = 'Weathertight Homes Resolution Services (Remedies) Amendment Bill'
    @second_bill_name = 'Building (Consent Authorities) Amendment Bill'
    @sub_name = 'Third Readings'
    @class = BillDebate
    @css_class = 'billdebate2'
    @publication_status = 'A'
    @bill_id = 111
    @bill_id2 = 112
    @date = Date.new(2007,8,16)

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

  it 'should create a speech with speaker correct when on behalf of' do
    @sub_debate.contributions.first.speaker.should == 'Hon JUDITH TIZARD (Minister of Consumer Affairs)'
  end

  it 'should create a speech with on behalf of correct when on behalf of' do
    @sub_debate.contributions.first.on_behalf_of.should == 'Minister for Building and Construction'
  end

  it 'should create a debate with no about' do
    @sub_debate.about_type.should == nil
    @sub_debate.about_id.should == nil
  end

  it 'should create a debate with two debate topics' do
    @sub_debate.debate_topics.size.should == 2
  end

  it 'should create a debate with first debate topic correct' do
    @sub_debate.debate_topics[0].topic_type.should == 'Bill'
  end

  it 'should create a debate with second debate topic correct' do
    @sub_debate.debate_topics[1].topic_type.should == 'Bill'
  end

  it 'should create a debate with debate topic ids correct' do
    ids = @sub_debate.debate_topics.collect {|t| t.topic_id }
    ids.include?(@bill_id).should be_true
    ids.include?(@bill_id2).should be_true
  end

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - Weathertight Homes Resolution Services (Remedies) Amendment Bill, Building (Consent Authorities) Amendment Bill — Third Readings</title>
<meta name="DC.Date" content="2007-08-16T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Weathertight Homes Resolution Services (Remedies) Amendment Bill, Building (Consent Authorities) Amendment Bill — Third Readings</h1>
    <a name="DocumentReference"></a>
    <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
    <div class="BillDebate2">
      <h2>Weathertight Homes Resolution Services (Remedies) Amendment Bill</h2>
      <h2>Building (Consent Authorities) Amendment Bill</h2>
      <div class="SubDebate">
        <h3>Third Readings</h3>
        <div class="Speech">
          <p class="Speech">
            <a name="time_17:55:40"></a>
            <strong>Hon JUDITH TIZARD (Minister of Consumer Affairs) </strong>on behalf of the<strong> Minister for Building and Construction</strong>: I move</p>
        </div>
      </div>
    </div>
  </div>
</div>
</body>
</html>|
  end
end
