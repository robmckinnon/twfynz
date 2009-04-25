require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed debate with DebateDebate div" do
  include ParserHelperMethods

  before do
    @name = 'Budget Statement'
    @sub_name = 'Budget Debate'
    @class = ParentDebate
    @css_class = 'debate'
    @publication_status = 'F'
    @date = Date.new(2006,5,18)

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

  it 'should create two sub-debates' do
    @debate.sub_debates.size.should == 2
  end

  it_should_behave_like "All parent debates"

  def html
    %Q|<html>
  <head>
    <title>New Zealand Parliament - Budget Statement — Budget Debate, Procedure</title>
    <meta name="DC.Date" content="2006-05-18T12:00:00.000Z" />
  </head>
  <body>
    <div class="copy">
      <div class="section">
        <a name="DocumentTitle"></a>
        <h1>Budget Statement — Budget Debate, Procedure</h1>
        <a name="DocumentReference"></a>
        <p>[Volume:631;Page:3195]</p>
        <div class="DebateDebate">
          <h2>Budget Statement</h2>
          <h2>Budget Debate</h2>
          <div class="Speech">
            <p class="Speech">
              <a name="time_14:03:07"></a>
              <strong>Hon Dr MICHAEL CULLEN (Minister of Finance)</strong>
              <strong>:</strong> I </p>
            <ul class="">
              <li>Debate interrupted.</li>
            </ul>
          </div>
          <h2>Procedure</h2>
          <div class="Speech">
            <p class="Speech">
              <a name="time_14:48:50"></a>
              <strong>Hon Dr MICHAEL CULLEN (Minister of Finance)</strong>
              <strong>:</strong> I </p>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>|
  end
end
