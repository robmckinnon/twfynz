require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed bill debate with three subdebates" do
  include ParserHelperMethods

  before do
    @name = 'Farmers’ Mutual Group Bill'
    @sub_name = 'Second Reading'
    @class = BillDebate
    @css_class = 'billdebate'
    @publication_status = 'A'
    @bill_id = 111
    @date = Date.new(2007,8,15)

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

  it_should_behave_like "All bill debates"

  it 'should create three sub-debates' do
    @debate.sub_debates.size.should == 3
  end

  it 'should set name correctly on each sub-debates' do
    @debate.sub_debates[0].name.should == 'Second Reading'
    @debate.sub_debates[1].name.should == 'Procedure'
    @debate.sub_debates[2].name.should == 'Third Reading'
  end

  def html
    %Q|<html>
  <head>
    <title>New Zealand Parliament - Farmers’ Mutual Group Bill — Second Reading, Procedure, Third Reading</title>
    <meta name="DC.Date" content="2007-08-15T12:00:00.000Z" />
  </head>
  <body>
    <div class="copy">
      <div class="section">
        <a name="DocumentTitle"></a>
        <h1>Farmers’ Mutual Group Bill — Second Reading, Procedure, Third Reading</h1>
        <a name="DocumentReference"></a>
        <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
        <div class="BillDebate">
          <h2>Farmers’ Mutual Group Bill</h2>
          <div class="SubDebate">
            <h3>Second Reading</h3>
          </div>
          <div class="SubDebate">
            <h3>Procedure</h3>
          </div>
          <div class="SubDebate">
            <h3>Third Reading</h3>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>|
  end
end
