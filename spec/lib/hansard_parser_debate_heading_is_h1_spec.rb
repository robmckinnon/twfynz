require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

describe HansardParser, "when passed Crimes (Substituted Section 59) Amendment Bill, Third Reading" do
  include ParserHelperMethods

  before do
    @name = 'Walking Access Bill'
    @sub_name = 'In Committee'
    @class = BillDebate
    @css_class = 'billdebate'
    @publication_status = 'A'
    @bill_id = 111
    @date = Date.new(2007,5,16)

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

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - Crimes (Substituted Section 59) Amendment Bill — Third Reading</title>
<meta name="DC.Date" content="2007-05-16T12:00:00.000Z" />
</head>
<body>
<div class="copy">
<div class="section">
    <a name="DocumentTitle"></a><h1>Walking Access Bill — In Committee</h1>
    <a name="DocumentReference"></a><p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
    <div class="BillDebate">
      <a name="page_19103"></a>
      <h1>Tuesday, 23 September 2008</h1>
      <p class="Urgency">(<em>continued on Thursday, 25 September 2008</em><strong></strong>)</p>
      <h1>Walking Access Bill</h1>
      <div class="SubDebate">
        <h2>In Committee</h2>
        <ul class="">
          <li>Debate resumed.</li>
        </ul>
        <div class="section">
          <h3>Part 2 New Zealand Walking Access Commission
 (<em>continued</em><strong></strong>) </h3>
        </div>
        <div class="Speech">
          <p class="Speech">
            <a name="time_09:00:26"></a>
            <strong>Hon Dr MICHAEL CULLEN (Leader of the House)</strong>
            <strong>:</strong> I move,
 <em>That the Committee report progress and sit again presently</em><strong></strong>.</p>
          <ul class="">
            <li>Progress reported.</li>
          </ul>
          <ul class="">
            <li>Report adopted.</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</div>
</body>
</html>|
  end
end
