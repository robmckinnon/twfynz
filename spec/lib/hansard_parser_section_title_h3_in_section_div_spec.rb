require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed bill debate with three subdebates" do
  include ParserHelperMethods

  before do
    @name = 'Estimates Debate'
    @sub_name = 'In Committee'
    @class = ParentDebate
    @css_class = 'debate'
    @publication_status = 'A'
    @bill_id = nil
    @date = Date.new(2009,8,18)

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

  it 'should create one sub-debate' do
    @debate.sub_debates.size.should == 1
  end

  it 'should set name correctly on each sub-debate' do
    @debate.sub_debates[0].name.should == 'In Committee'
  end

  it 'should set name correctly on each sub-debate' do
    @debate.sub_debates[0].contributions[0].text.should == '<p>Debate resumed from 6 August on the Appropriation (2009/10 Estimates) Bill.</p>'
  end

  it 'should set name correctly on each sub-debate' do
    @debate.sub_debates[0].contributions[1].should be_an_instance_of(SectionHeader)
  end

  def html
    %Q|<html>
  <head>
    <title>New Zealand Parliament -     Estimates Debate — In Committee</title>
    <meta name="DC.Date" content="2009-08-18T12:00:00.000Z" />
  </head>
  <body>
    <div class="copy">
      <div class="section">
        <a name="DocumentTitle"></a>
        <h1>Estimates Debate — In Committee</h1>
        <a name="DocumentReference"></a>
        <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
        <div class="Debate">
          <h1>Estimates Debate</h1>
          <div class="SubDebate">
            <h2>In Committee</h2>
            <ul class="">
              <li>Debate resumed from 6 August on the Appropriation (2009/10 Estimates) Bill.</li>
            </ul>
            <div class="section">
              <h3>Vote Climate Change (continued) </h3>
            </div>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>|
  end
end
