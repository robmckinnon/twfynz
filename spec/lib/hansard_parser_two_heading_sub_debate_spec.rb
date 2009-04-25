require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed debate with two heading subdebate" do
  include ParserHelperMethods

  before do
    @name = 'Privilege'
    @sub_name = 'Consideration of Report of Privileges Committee, Members’ Pecuniary Interests—Gifts and Donations'
    @class = ParentDebate
    @css_class = 'debate'
    @publication_status = 'A'
    @bill_id = nil
    @date = Date.new(2008, 9, 23)

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

  it 'should create one sub-debates' do
    @debate.sub_debates.size.should == 1
  end

  it 'should create slug using second sub_debate h2 heading' do
    @sub_debate.create_url_slug
    @sub_debate.url_slug.should == 'members_pecuniary_interests'
  end

  def html
    %Q|<html>
  <head>
    <title>New Zealand Parliament - Privilege — Consideration of Report of Privileges Committee, Members’ Pecuniary Interests—Gifts and Donations</title>
    <meta name="DC.Date" content="2008-09-23T12:00:00.000Z" />
  </head>
  <body>
    <div class="copy">
      <div class="section">
      <a name="DocumentTitle"></a>
      <h1>Privilege — Consideration of Report of Privileges Committee, Members’ Pecuniary Interests—Gifts and Donations</h1>
      <a name="DocumentReference"></a>
      <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
      <div class="Debate">
        <h2>Privilege</h2>
        <div class="SubDebate">
          <h3>Consideration of Report of Privileges Committee</h3>
        </div>
        <div class="SubDebate">
          <h3>Members’ Pecuniary Interests—Gifts and Donations</h3>
          <div class="Speech">
            <p class="Speech">
              <a name="time_15:25:27"></a>
              <strong>PETER BROWN (Whip—NZ First)</strong>
              <strong>:</strong> I raise a point of order, Madam Speaker. At the conclusion of this debate we will take a vote, and it is a very serious issue, to my mind. As you are well aware, I wrote to you and asked that it be a personal vote, in the interests of justice. You declined that, and I just wondered whether you could spare a few moments of the House’s time to explain why it was declined.</p>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>|
  end
end
