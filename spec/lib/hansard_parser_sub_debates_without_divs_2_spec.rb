require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed debate with subdebates outside divs" do
  include ParserHelperMethods

  before do
    @name = 'Points of Order'
    @sub_name = 'Questions for Written Answer—Content of Answers'
    @class = Debate
    @css_class = 'debate'
    @publication_status = 'A'
    # @bill_id = 111
    @date = Date.new(2009,4,9)

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

  it 'should create three sub-debates' do
    @debate.sub_debates.size.should == 4
  end

=begin
  it_should_behave_like "All parent debates"

  it 'should set name correctly on each sub-debates' do
    @debate.sub_debates[0].name.should == 'Questions for Written Answer—Content of Answers'
    @debate.sub_debates[1].name.should == 'Questions for Oral Answer—Unauthenticated Statements in Questions'
    @debate.sub_debates[2].name.should == 'Chamber—Audio System'
    @debate.sub_debates[3].name.should == 'Resignation—Member for Mt Albert'
  end

  it 'should add contributions for sub debates outside of div' do
    @debate.sub_debates[1].contributions.first.should be_an_instance_of(Speech)
    @debate.sub_debates[2].contributions.first.should be_an_instance_of(Speech)
    @debate.sub_debates[3].contributions.first.should be_an_instance_of(Speech)
  end
=end
  def html
    %Q|<html>
  <head>
    <title>New Zealand Parliament - Points of Order — Questions for Written Answer—Content of Answers, Questions for Oral Answer—Unauthenticated Statements in Questions, Chamber—Audio System, Resignation—Member for Mt Albert</title>
    <meta name="DC.Date" content="2009-04-09T12:00:00.000Z" />
  </head>
  <body>
    <div class="copy">
      <div class="section">
        <a name="DocumentTitle"></a>
        <h1>Points of Order — Questions for Written Answer—Content of Answers, Questions for Oral Answer—Unauthenticated Statements in Questions, Chamber—Audio System, Resignation—Member for Mt Albert</h1>
        <a name="DocumentReference"></a>
        <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
        <div class="Debate">
          <h2>Points of Order</h2>
          <div class="SubDebate">
            <h2>Questions for Written Answer—Content of Answers</h2>
            <div class="Speech">
              <p class="Speech">
                <strong>Hon CLAYTON COSGROVE (Labour—Waimakariri)</strong>
                <strong>:</strong> I raise a point of order, Mr Speaker.</p>
            </div>
          </div>
          <h2>Questions for Oral Answer—Unauthenticated Statements in Questions</h2>
          <div class="Speech">
            <p class="Speech">
              <strong>Hon Dr NICK SMITH (Minister for ACC)</strong>
              <strong>:</strong> I raise a point of order, Mr Speaker.</p>
          </div>
          <h2>Chamber—Audio System</h2>
          <div class="Speech">
            <p class="Speech">
              <strong>Hon PETER DUNNE (Leader—United Future)</strong>
              <strong>:</strong> I raise a point of order, Mr Speaker.</p>
          </div>
          <h2>Resignation—Member for Mt Albert</h2>
          <div class="Speech">
            <p class="Speech">
              <strong>JEANETTE FITZSIMONS (Co-Leader—Green)</strong>
              <strong>:</strong> I raise a point of order, Mr Speaker.</p>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>|
  end
end
