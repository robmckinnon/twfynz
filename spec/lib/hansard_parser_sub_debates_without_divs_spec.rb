require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed bill debate with three subdebates" do
  include ParserHelperMethods

  before do
    @name = 'Bail Amendment Bill'
    @sub_name = 'First Reading'
    @class = BillDebate
    @css_class = 'billdebate'
    @publication_status = 'A'
    @bill_id = 111
    @date = Date.new(2008,12,12)

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
    @debate.sub_debates.size.should == 4
  end

  it 'should set name correctly on each sub-debates' do
    @debate.sub_debates[0].name.should == 'First Reading'
    @debate.sub_debates[1].name.should == 'Second Reading'
    @debate.sub_debates[2].name.should == 'In Committee'
    @debate.sub_debates[3].name.should == 'Third Reading'
  end

  it 'should add contributions for sub debate outside of div' do
    @debate.sub_debates[2].contributions.first.should be_an_instance_of(SectionHeader)
    @debate.sub_debates[2].contributions.last.should be_an_instance_of(Speech)
  end

  def html
    %Q|<html>
  <head>
    <title>New Zealand Parliament - Bail Amendment Bill — First Reading, Second Reading, In Committee, Third Reading</title>
    <meta name="DC.Date" content="2008-12-09T12:00:00.000Z" />
  </head>
  <body>
    <div class="copy">
      <div class="section">
        <a name="DocumentTitle"></a>
        <h1>Bail Amendment Bill — First Reading, Second Reading, In Committee, Third Reading</h1>
        <a name="DocumentReference"></a>
        <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
        <div class="BillDebate">
          <h1>Tuesday, 9 December 2008</h1>
          <h1>Bail Amendment Bill</h1>
          <div class="SubDebate">
            <h2>First Reading</h2>
          </div>
          <div class="SubDebate">
            <h2>Second Reading</h2>
          </div>
          <h1>In Committee</h1>
          <div class="section">
            <h3>Part 1 Part 6A repealed</h3>
          </div>
          <div class="Speech">
            <p class="Speech">
              <a name="time_21:54:35"></a>
              <strong>Hon DAVID PARKER (Labour)</strong>
              <strong>:</strong> I would like to begin</p>
            </p>
          </div>
          <h1>Third Reading</h1>
        </div>
      </div>
    </div>
  </body>
</html>|
  end
end
