require File.dirname(__FILE__) + '/hansard_parser_spec_helper'


describe HansardParser, "when passed Business Statement 2007-07-19" do
  before(:all) do
    @name = 'Business Statement'
    @publication_status = 'A'
    @date = Date.new(2007,7,19)
    @debate_index = 1
    HansardParser.stub!(:load_file).and_return html
    @debate = parse_hansard 'nil', @debate_index
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All alone debates"

  it 'should create correct number of contributions for debate alone' do
    @debate.contributions.size.should == 3
  end

  it 'should create a speech contribution for a "Speech" paragraph in debate alone' do
    @debate.contributions.first.should be_an_instance_of(Speech)
    @debate.contributions.first.text.should == '<p>Next week in the House progress is to be made on the next stages of the Weathertight Homes Resolution Services (Remedies) Amendment Bill, the Mental Health Commission Amendment Bill, the Wills Bill, and the Major Events Management Bill. Priority will also be given to the first readings of the Social Assistance (Debt Prevention and Minimisation) Amendment Bill, and the Electricity (Disconnection and Low Fixed Charges) Amendment Bill. Wednesday is a members’ day.</p>'
  end

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - Business Statement</title>
<meta name="DC.Date" content="2007-07-19T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Business Statement</h1>
    <a name="DocumentReference"></a>
    <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
    <div class="DebateAlone">
      <a name="page_10539"></a>
      <h2>Thursday, 19 July 2007</h2>
      <p class="a"><strong>Madam Speaker</strong> took the Chair at 2 p.m.</p>
      <p class="a"><strong>Prayers</strong>.</p>
      <h2>Business Statement</h2>
      <div class="Speech"><p class="Speech"><a name="time_13:59:40"></a>
        <strong>Hon Dr MICHAEL CULLEN (Leader of the House)</strong>
        <strong>:</strong> Next week in the House progress is to be made on the next stages of the Weathertight Homes Resolution Services (Remedies) Amendment Bill, the Mental Health Commission Amendment Bill, the Wills Bill, and the Major Events Management Bill. Priority will also be given to the first readings of the Social Assistance (Debt Prevention and Minimisation) Amendment Bill, and the Electricity (Disconnection and Low Fixed Charges) Amendment Bill. Wednesday is a members’ day.</p>
      </div>
      <div class="Speech"><p class="Speech"><a name="time_14:00:10"></a>
        <strong>GERRY BROWNLEE (National—Ilam)</strong>
        <strong>:</strong> In</p>
      </div>
      <div class="Speech"><p class="Speech"><a name="time_14:00:31"></a>
        <strong>Hon Dr MICHAEL CULLEN (Leader of the House)</strong>
        <strong>:</strong> I</p>
      </div>
    </div>
  </div>
</div>
</body>
</html>|
  end
end


describe HansardParser, "when passed Tabling of Documents — Code of Conduct for Members of Parliament 2007-08-09" do
  before(:all) do
    @name = 'Tabling of Documents'
    @sub_name = 'Code of Conduct for Members of Parliament'
    @class = ParentDebate
    @css_class = 'debate'
    @publication_status = 'A'
    @date = Date.new(2007,8,9)
    @debate_index = 1
    HansardParser.stub!(:load_file).and_return html
    @debate = parse_hansard '48HansD_20070809_00000052-Tabling-of-Documents-Code-of-Conduct-for.htm', @debate_index
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
<title>New Zealand Parliament - Tabling of Documents — Code of Conduct for Members of Parliament</title>
<meta name="DC.Date" content="2007-08-09T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Tabling of Documents — Code of Conduct for Members of Parliament</h1>
    <a name="DocumentReference"></a>
    <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>

    <div class="Debate">
      <h2>Tabling of Documents</h2>
      <h2>Code of Conduct for Members of Parliament</h2>
      <div class="Speech">
        <p class="Speech">
          <a name="time_14:03:02"></a>
          <strong>Dr PITA SHARPLES (Co-Leader—Māori Party)</strong>
          <strong>:</strong> I seek leave to table my signed copy of the code of conduct for members of Parliament. I was away at the time when our parties put this forward.</p>
        <ul class="">
          <li>Document, by leave, laid on the Table of the House.</li>
        </ul>
      </div>
    </div>
  </div>
</div>
</body>
</html>|
  end
end


describe HansardParser, "when passed Points-of-Order with two subdebates" do
  before(:all) do
    @name = 'Points of Order'
    @sub_name = 'Auditor-General—Officers of Parliament Committee'
    @class = ParentDebate
    @css_class = 'debate'
    @publication_status = 'A'
    @date = Date.new(2007,8,9)
    @debate_index = 1
    HansardParser.stub!(:load_file).and_return html
    @debate = parse_hansard 'nil', @debate_index
    @sub_debate = @debate.sub_debate
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All parent debates"

  it 'should create a debate with two sub-debates' do
    @debate.sub_debates.size.should == 2
  end

  it 'should set the name of a second sub-debate correctly' do
    @debate.sub_debates[1].name.should == 'Select Committees—Official Business'
  end

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - Points of Order — Auditor-General—Officers of Parliament Committee, Select Committees—Official Business</title>
<meta name="DC.Date" content="2007-08-09T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Points of Order — Auditor-General—Officers of Parliament Committee, Select Committees—Official Business</h1>
    <a name="DocumentReference"></a>
    <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
    <div class="Debate">
      <h2>Points of Order</h2>
      <div class="SubDebate">
        <h3>Auditor-General—Officers of Parliament Committee</h3>
        <div class="Speech">
          <p class="Speech">
            <strong>PETER BROWN (Whip—NZ First)</strong>
            <strong>:</strong> I say.</p>
        </div>
      </div>
      <div class="SubDebate">
        <h3>Select Committees—Official Business</h3>
        <div class="Speech">
          <p class="Speech">
            <strong>PETER BROWN (Whip—NZ First)</strong>
            <strong>:</strong> I say again.</p>
        </div>
      </div>
    </div>
  </div>
</div>
</body>
</html>|
  end
end


describe HansardParser, "when passed Motions — Military Awards—Victoria Cross, Gallantry Decoration, Gallantry Medal 2007-07-17" do
  before(:all) do
    @name = 'Motions'
    @sub_name = 'Military Awards—Victoria Cross, Gallantry Decoration, Gallantry Medal'
    @class = ParentDebate
    @css_class = 'debate'
    @publication_status = 'A'
    @date = Date.new(2007,7,17)
    @debate_index = 1
    HansardParser.stub!(:load_file).and_return html
    @debate = parse_hansard 'nil', @debate_index
    @sub_debate = @debate.sub_debate
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All parent debates"

  it 'should allow em element content to be in a Speech text attribute' do
    @sub_debate.contributions.first.should be_an_instance_of(Speech)
    @sub_debate.contributions.first.text.should == '<p>I move, <em>That</em></p>'
  end

  it 'should create a procedural contribution for a ul element in a "Speech" div' do
    @sub_debate.contributions[1].should be_an_instance_of(Procedural)
    @sub_debate.contributions[1].text.should == '<p>Motion agreed to.</p>'
  end

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - Motions — Military Awards—Victoria Cross, Gallantry Decoration, Gallantry Medal</title>
<meta name="DC.Date" content="2007-07-17T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Motions — Military Awards—Victoria Cross, Gallantry Decoration, Gallantry Medal</h1>
    <a name="DocumentReference"></a>
    <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>

    <div class="Debate">
      <h2>Motions</h2>
      <div class="SubDebate">
        <h3>Military Awards—Victoria Cross, Gallantry Decoration, Gallantry Medal</h3>
        <div class="Speech">
          <p class="Speech">
            <a name="time_14:03:53"></a>
            <strong>Hon PHIL GOFF (Minister of Defence)</strong>
            <strong>:</strong> I move, <em>That</em></p>
          <ul class="">
            <li>Motion agreed to.</li>
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


describe HansardParser, "when passed Speaker’s Rulings — Documents Tabled By Leave—Release 2007-07-17" do
  before(:all) do
    @name = 'Speaker’s Rulings'
    @sub_name = 'Documents Tabled By Leave—Release'
    @class = ParentDebate
    @css_class = 'debate'
    @publication_status = 'A'
    @date = Date.new(2007,7,17)
    @debate_index = 1
    HansardParser.stub!(:load_file).and_return html
    @debate = parse_hansard 'nil', @debate_index
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
<title>New Zealand Parliament - Speaker’s Rulings — Documents Tabled By Leave—Release</title>
<meta name="DC.Date" content="2007-07-17T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Speaker’s Rulings — Documents Tabled By Leave—Release</h1>
    <a name="DocumentReference"></a>
    <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
    <div class="Debate">
      <h2>Speaker’s Rulings</h2>
      <div class="SubDebate">
        <h3>Documents Tabled By Leave—Release</h3>
        <div class="Speech">
          <p class="Speech">
            <a name="time_14:05:11"></a>
            <strong>Madam SPEAKER</strong>: On</p>
         </div>
      </div>
    </div>
  </div>
</div>
</body>
</html>|
  end
end


describe HansardParser, "when passed Visitors — Niue—Speaker of the Legislative Assembly 2007-07-18" do
  before(:all) do
    @name = 'Visitors'
    @sub_name = 'Niue—Speaker of the Legislative Assembly'
    @class = ParentDebate
    @css_class = 'debate'
    @publication_status = 'A'
    @date = Date.new(2007,7,18)
    @debate_index = 1
    HansardParser.stub!(:load_file).and_return html
    @debate = parse_hansard 'nil', @debate_index
    @sub_debate = @debate.sub_debate
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it 'should create speech contribution for speech div' do
    @sub_debate.contributions[0].should_not be_nil
    @sub_debate.contributions[0].should be_an_instance_of(Speech)
    @sub_debate.contributions[0].text.should == '<p>I</p>'
    @sub_debate.contributions[0].speaker.should == 'Madam SPEAKER'
  end

  it 'should create procedural contribution for ul element' do
    @sub_debate.contributions[1].should_not be_nil
    @sub_debate.contributions[1].should be_an_instance_of(Procedural)
    @sub_debate.contributions[1].text.should == '<p>The</p>'
  end

  it_should_behave_like "All parent debates"

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - Visitors — Niue—Speaker of the Legislative Assembly</title>
<meta name="DC.Date" content="2007-07-18T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Visitors — Niue—Speaker of the Legislative Assembly</h1>
    <a name="DocumentReference"></a>
    <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
    <div class="Debate">
      <a name="page_10453"></a>
      <h2>Wednesday, 18 July 2007</h2>
      <p class="a"><strong>Madam Speaker</strong> took the Chair at 2 p.m.</p>
      <p class="a"><strong>Prayers</strong>.</p>
      <h2>Visitors</h2>
      <div class="SubDebate">
        <h3>Niue—Speaker of the Legislative Assembly</h3>
        <div class="Speech">
          <p class="Speech"><a name="time_13:59:38"></a>
            <strong>Madam SPEAKER</strong>: I </p>
          <ul class="">
            <li>The</li>
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


describe HansardParser, "when passed General Debate 2007-07-18" do
  before(:all) do
    @name = 'General Debate'
    @publication_status = 'A'
    @date = Date.new(2007,7,18)
    @debate_index = 1
    HansardParser.stub!(:load_file).and_return html
    @debate = parse_hansard 'nil', @debate_index
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All alone debates"

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - General Debate</title>
<meta name="DC.Date" content="2007-07-18T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a><h1>General Debate</h1><a name="DocumentReference"></a><p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
    <div class="DebateAlone">
      <h2>General Debate</h2>
      <div class="Speech">
        <p class="Speech">
          <a name="time_15:28:30"></a>
          <strong>Hon BILL ENGLISH (Deputy Leader—National)</strong>
          <strong>:</strong> I </p></div>
      </div>
    </div>
  </div>
</body>
</html>|
  end
end


describe HansardParser, "when passed General Debate with a ContinueSpeech without speaker name following a Speech" do
  before(:all) do
    @name = 'General Debate'
    @publication_status = 'A'
    @date = Date.new(2007,7,18)
    @debate_index = 1
    HansardParser.stub!(:load_file).and_return html

    @debate = parse_hansard 'nil', @debate_index
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All alone debates"

  it 'should not raise error when validated' do
    @debate.contributions.first.should_receive(:populate_spoken_by_id_from_mp).with('LYNNE PILLAY (Labour—Waitakere)')
    lambda { @debate.valid? }.should_not raise_error
  end

  it 'should have one contribution for Speech and ContinueSpeech' do
    @debate.contributions.size.should == 1
  end

  it 'should have one contribution text for Speech and ContinueSpeech, containing two paragraphs' do
    @debate.contributions.first.text.should == '<p>I</p><p>It</p>'
  end

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - General Debate</title>
<meta name="DC.Date" content="2007-07-18T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a><h1>General Debate</h1><a name="DocumentReference"></a><p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
    <div class="DebateAlone">
      <h2>General Debate</h2>
      <div class="Speech">
        <p class="Speech">
          <strong>LYNNE PILLAY (Labour—Waitakere)</strong>
          <strong>:</strong> I </p>
        <p class="ContinueSpeech">It </p>
      </div>
    </div>
  </div>
</div>
</body>
</html>|
  end
end


describe HansardParser, "when passed Points of Order — Reserve Bank (Amending Primary Function of Bank) Amendment Bill—Leave to Introduce 2007-07-19" do
  before(:all) do
    @name = 'Points of Order'
    @sub_name = 'Reserve Bank (Amending Primary Function of Bank) Amendment Bill—Leave to Introduce'
    @class = ParentDebate
    @css_class = 'debate'
    @publication_status = 'A'
    @date = Date.new(2007,7,19)
    @debate_index = 1
    HansardParser.stub!(:load_file).and_return html
    @debate = parse_hansard 'nil', @debate_index
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
<title>New Zealand Parliament - Points of Order — Reserve Bank (Amending Primary Function of Bank) Amendment  Bill—Leave to Introduce </title>
<meta name="DC.Date" content="2007-07-19T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Points of Order — Reserve Bank (Amending Primary Function of Bank) Amendment  Bill—Leave to Introduce </h1>
    <a name="DocumentReference"></a>
    <p>[Advance Copy - Subject to minor change before inclusion in Bound Volume.]</p>
    <div class="Debate">
      <h2>Points of Order</h2>
      <div class="SubDebate">
        <h3>Reserve Bank (Amending Primary Function of Bank) Amendment Bill—Leave to Introduce</h3>
        <div class="Speech">
          <p class="Speech">
            <strong>PETER BROWN (Whip—NZ First)</strong>
            <strong>:</strong> I say.</p>
        </div>
      </div>
    </div>
  </div>
</div>
</div>
</body>
</html>|
  end
end


describe HansardParser, "when passed Business of the House 2007-06-19" do
  before(:all) do
    @name = 'Business of the House'
    @publication_status = 'F'
    @date = Date.new(2007,6,19)
    @debate_index = 1
    HansardParser.stub!(:load_file).and_return html
    @debate = parse_hansard 'nil', @debate_index
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All alone debates"

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - Business of the House</title>
<meta name="DC.Date" content="2007-06-19T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>Business of the House</h1>
    <a name="DocumentReference"></a>
    <p>[Volume:640;Page:9933]</p>
    <div class="DebateAlone">
      <a name="page_9933"></a>
      <h2>Tuesday, 19 June 2007</h2>
      <p class="a"><strong>Madam Speaker</strong> took the Chair at 2 p.m.</p>
      <p class="a"><strong>Prayers</strong>.</p>
      <h2>Business of the House</h2>
      <div class="Speech">
        <p class="Speech">
          <a name="time_14:01:28"></a>
          <strong>Hon Dr MICHAEL CULLEN (Leader of the House)</strong>
          <strong>:</strong> Pursuant</p>
        <p class="Interjection">
          <strong>Madam SPEAKER</strong>: Is</p>
      </div>
    </div>
  </div>
</div>
</body>
</html>|
  end
end
