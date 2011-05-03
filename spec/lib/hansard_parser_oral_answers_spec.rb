require File.dirname(__FILE__) + '/hansard_parser_oral_answers_spec_helper'

describe HansardParser, " when passed Oral Question: 1. Electoral Finance Bill—Select Committee Changes" do
  include OralQuestionHelperMethods

  before do
    @file_name = 'nil'
    @name = 'Electoral Finance Bill—Select Committee Changes'
    @debate_index = 2
    @publication_status = 'U'
    @date = Date.new 2007,8,15
    @oral_answer_no = 1
    @about_id = 123
    @answer_from_id = 456
    @asking_mp_id = 789
    @other_asking_mp_id = 102
    @yet_other_asking_mp_id = 103
    @asking_mp_name = 'JOHN KEY (Leader of the Opposition)'
    @question_text = '<p>Which</p>'
    @answering_mp_id = 245
    @answering_mp_name = 'Hon STEVE MAHAREY (Minister of Education)'
    @answering_on_behalf_of = 'Prime Minister'
    @answer_text = '<p>The</p>'
    @answer_from_name = 'Prime Minister'
    @answer_from_type = Minister
    @about_type_attribute = :portfolio
    @about_type = Portfolio
    @answer_time = '14:04:02'

    @supplimentary_questioners_names = [
        'John Key',
        'Darren Hughes',
        'John Key',
        'John Key',
        'Rt Hon Winston Peters',
        'John Key',
        'Rt Hon Winston Peters',
        'John Key',
        'John Key'
    ]
    @supplimentary_questioners_ids = [
      @asking_mp_id,
      @other_asking_mp_id,
      @asking_mp_id,
      @asking_mp_id,
      @yet_other_asking_mp_id,
      @asking_mp_id,
      @yet_other_asking_mp_id,
      @asking_mp_id,
      @asking_mp_id
    ]

    @first_suplimentary_mp_name = 'John Key'
    @first_suplimentary_mp_id = @asking_mp_id
    @first_suplimentary_question_text = '<p>What</p>'

    @supplimentary_answerer_name = 'Hon STEVE MAHAREY'
    @first_suplimentary_answer_text = '<p>As</p>'

    @interjecter_names = []
    @interjecter_ids = []
    HansardParser.stub!(:load_file).and_return html
    parse_debate
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All oral questions"

  def html
    %Q|<html>
  <head>
    <title>New Zealand Parliament - 1. Electoral Finance Bill—Select Committee Changes</title>
    <meta name="DC.Date" content="2007-08-15T12:00:00.000Z" />
  </head>
  <body>
    <div class="copy">
      <div class="section">
        <a name="DocumentTitle"></a>
        <h1>1. Electoral Finance Bill —Select Committee Changes</h1>
        <a name="DocumentReference"></a>
        <p>[Uncorrected transcript—subject to correction and further editing.]</p>
        <div class="SubsQuestion">
          <p class="SubsQuestion">
            <strong>1. JOHN KEY (Leader of the Opposition)</strong> to the
 <strong>Prime Minister</strong>: Which</p>
          <p class="SubsAnswer">
            <a name="time_14:04:02"></a>
            <strong>Hon STEVE MAHAREY (Minister of Education)</strong> on behalf of the<strong> Prime Minister</strong>: The</p>
          <p class="SupQuestion">
            <strong>John Key</strong>: What</p>
          <p class="SupAnswer">
            <strong>Hon STEVE MAHAREY</strong>: As</p>
        </div>
      </div>
    </div>
  </body>
</html>|
  end
end



describe HansardParser, " when passed Oral Question: 3. Oil Market—Supply 2007-07-26" do
  include OralQuestionHelperMethods

  before do
    @file_name = 'nil'
    @name = 'Oil Market—Supply'
    @debate_index = 2
    @publication_status = 'U'
    @date = Date.new 2007,7,26
    @oral_answer_no = 3
    @about_id = 123
    @answer_from_id = 456
    @asking_mp_id = 789
    @other_asking_mp_id = 102
    @asking_mp_name = 'JEANETTE FITZSIMONS (Co-Leader—Green)'
    @question_text = '<p>What</p>'
    @answering_mp_id = 245
    @answering_mp_name = 'Hon Dr MICHAEL CULLEN (Minister of Finance)'
    @answer_text = '<p>Low</p>'
    @answer_from_name = 'Minister of Finance'
    @answer_from_type = Minister
    @about_type_attribute = :portfolio
    @about_type = Portfolio
    @answer_time = '14:14:39'

    @supplimentary_questioners_names = [
      'Jeanette Fitzsimons',
      'Gordon Copeland',
      'Jeanette Fitzsimons',
      'Jeanette Fitzsimons',
      'Jeanette Fitzsimons'
    ]
    @supplimentary_questioners_ids = [
      @asking_mp_id,
      @other_asking_mp_id,
      @asking_mp_id,
      @asking_mp_id,
      @asking_mp_id
    ]

    @first_suplimentary_mp_name = 'Jeanette Fitzsimons'
    @first_suplimentary_mp_id = @asking_mp_id
    @first_suplimentary_question_text = '<p>Will</p>'

    @supplimentary_answerer_name = 'Hon Dr MICHAEL CULLEN'
    @first_suplimentary_answer_text = '<p>I</p>'

    @interjecter_names = ['Jeanette Fitzsimons','Madam SPEAKER']
    @interjecter_ids = [@asking_mp_id,202]
    HansardParser.stub!(:load_file).and_return html
    parse_debate
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All oral questions"

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - 3. Oil Market—Supply</title>
<meta name="DC.Date" content="2007-07-26T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>3. Oil Market—Supply</h1>
    <a name="DocumentReference"></a>
    <p>[Uncorrected transcript—subject to correction and further editing.]</p>
    <div class="SubsQuestion">
      <p class="SubsQuestion">
        <strong>3. </strong>
        <strong>JEANETTE FITZSIMONS (Co-Leader—Green)</strong> to the <strong>Minister of Finance</strong>: What</p>
      <p class="SubsAnswer">
        <a name="time_14:14:39"></a>
        <strong>Hon Dr MICHAEL CULLEN (Minister of Finance)</strong>
        <strong>:</strong> Low</p>
      <p class="SupQuestion"><strong>Jeanette Fitzsimons</strong>: Will</p>
      <p class="SupAnswer"><strong>Hon Dr MICHAEL CULLEN</strong>: I</p>
      <a name="page_5"></a>
      <p class="SupQuestion"><strong>Gordon Copeland</strong>: Can</p>
      <p class="SupAnswer"><strong>Hon Dr MICHAEL CULLEN</strong>: I</p>
      <p class="SupQuestion"><strong>Jeanette Fitzsimons</strong>: Does</p>
      <p class="SupAnswer"><strong>Hon Dr MICHAEL CULLEN</strong>: To</p>
      <p class="SupQuestion"><strong>Jeanette Fitzsimons</strong>: What</p>
      <p class="SupAnswer"><strong>Hon Dr MICHAEL CULLEN</strong>: The</p>
      <p class="SupQuestion"><strong>Jeanette Fitzsimons</strong>: Can</p>
      <p class="SupAnswer"><strong>Hon Dr MICHAEL CULLEN</strong>: I</p>
      <p class="Interjection"><strong>Jeanette Fitzsimons</strong>: I</p>
      <p class="Interjection"><strong>Madam SPEAKER</strong>: Leave</p>
      <a name="page_6"></a>
    </div>
  </div>
</div>
</body>
</html>|
  end
end


describe HansardParser, " when passed Oral Question: 4. Dalai Lama—Government Welcome 2007-06-19" do
  include OralQuestionHelperMethods

  before do
    @name = 'Dalai Lama—Government Welcome'
    @file_name = 'nil'
    @debate_index = 2
    @publication_status = 'F'
    @date = Date.new 2007,6,19
    @oral_answer_no = 4
    @about_id = 123
    @answer_from_id = 456
    @asking_mp_id = 789
    @asking_mp_name = 'KEITH LOCKE (Green)'
    @question_text = '<p>What</p>'
    @answering_mp_id = 245
    @answering_mp_name = 'Rt Hon HELEN CLARK (Prime Minister)'
    @answer_text = '<p>The</p>'
    @answer_from_name = 'Prime Minister'
    @answer_from_type = Minister
    @about_type_attribute = :portfolio
    @about_type = Portfolio
    @answer_time = '14:25:17'

    @supplimentary_questioners_names = [
      'Keith Locke',
      'Keith Locke',
      'Keith Locke'
    ]
    @supplimentary_questioners_ids = [
      @asking_mp_id,
      @asking_mp_id,
      @asking_mp_id
    ]

    @first_suplimentary_mp_name = 'Keith Locke'
    @first_suplimentary_mp_id = @asking_mp_id
    @first_suplimentary_question_text = '<p>Does</p>'

    @supplimentary_answerer_name = 'Rt Hon HELEN CLARK'
    @first_suplimentary_answer_text = '<p>On</p>'

    @interjecter_names = []
    HansardParser.stub!(:load_file).and_return html
    parse_debate
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All oral questions"

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - 4. Dalai Lama—Government Welcome</title>
<meta name="DC.Date" content="2007-06-19T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>4. Dalai Lama—Government Welcome</h1>
    <a name="DocumentReference"></a>
    <p>[Volume:640;Page:9938]</p>
    <div class="SubsQuestion">
      <p class="SubsQuestion"><strong>4. KEITH LOCKE (Green)</strong> to the <strong>Prime Minister</strong>: What</p>
      <p class="SubsAnswer"><a name="time_14:25:17"></a>
        <strong>Rt Hon HELEN CLARK (Prime Minister)</strong>
        <strong>:</strong> The</p>
      <p class="SupQuestion"><strong>Keith Locke</strong>: Does</p>
      <p class="SupAnswer"><strong>Rt Hon HELEN CLARK</strong>: On</p>
      <p class="SupQuestion"><strong>Keith Locke</strong>: Is</p>
      <p class="SupAnswer"><strong>Rt Hon HELEN CLARK</strong>: No</p>
      <p class="SupQuestion"><strong>Keith Locke</strong>: Does</p>
      <a name="page_9939"></a>
      <p class="SupAnswer"><strong>Rt Hon HELEN CLARK</strong>: I</p>
    </div>
  </div>
</div>
</body>
</html>|
  end
end


describe HansardParser, " when passed 1. Finance and Expenditure Committee—Television New Zealand Inquiry 2006-02-21" do
  include OralQuestionHelperMethods

  before do
    @name = 'Finance and Expenditure Committee—Television New Zealand Inquiry'
    @file_name = '48HansQ_20060221_00000742-1-Finance-and-Expenditure-Committee-Television.htm'
    @debate_index = 2
    @publication_status = 'F'
    @date = Date.new 2006,2,21
    @oral_answer_no = 1
    @about_id = 123
    @answer_from_id = 456
    @answer_from_name = 'Chairperson of the Finance and Expenditure Committee'
    @asking_mp_id = 789
    @asking_mp_name = 'RODNEY HIDE (Leader—ACT)'
    @question_text = '<p>Does</p>'
    @answering_mp_id = 245
    @answering_mp_name = 'SHANE JONES (Chairperson of the Finance and Expenditure Committee)'
    @answer_text = '<p>Yes.</p>'
    @answer_from_type = CommitteeChair
    @about_type_attribute = :committee
    @about_type = Committee
    @answer_time = '15:24:50'

    @supplimentary_questioners_names = ['Rodney Hide']
    @supplimentary_questioners_ids = [@asking_mp_id]

    @first_suplimentary_mp_name = 'Rodney Hide'
    @first_suplimentary_mp_id = @asking_mp_id
    @first_suplimentary_question_text = '<p>Could</p>'
    @supplimentary_answerer_name = 'SHANE JONES'
    @first_suplimentary_answer_text = '<p>I</p>'
    @interjecter_names = []
    HansardParser.stub!(:load_file).and_return html
    parse_debate
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All oral questions"

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - 1. Finance and Expenditure Committee—Television New Zealand Inquiry</title>
<meta name="DC.Date" content="2006-02-21T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>1. Finance and Expenditure Committee—Television New Zealand Inquiry</h1>
    <a name="DocumentReference"></a>
    <p>[Volume:629;Page:1286]</p>
    <div class="SubsQuestion">
      <p class="SubsQuestion">
        <strong>1. </strong> <strong>RODNEY HIDE (Leader—ACT)</strong> to the <strong>Chairperson of the Finance and Expenditure Committee</strong>: Does</p>
      <p class="SubsAnswer">
        <a name="time_15:24:50"></a>
        <strong>SHANE JONES (Chairperson of the Finance and Expenditure Committee)</strong>
        <strong>:</strong> Yes.</p>
      <p class="SupQuestion"><strong>Rodney Hide</strong>: Could</p>
      <p class="SupAnswer"><strong>SHANE JONES</strong>: I</p>
      <a name="page_1287"></a>
    </div>
  </div>
</div>
</body>
</html>|
  end
end


describe HansardParser, " when passed 1. Crimes (Substituted Section 59) Amendment Bill—Reasonable Force Amendment 2007-03-28" do
  include OralQuestionHelperMethods

  before do
    @name = 'Crimes (Substituted Section 59) Amendment Bill—Reasonable Force Amendment'
    @file_name = 'nil'
    @debate_index = 2
    @publication_status = 'F'
    @date = Date.new 2007,3,28
    @oral_answer_no = 1
    @about_id = 123
    @answer_from_id = 456
    @answer_from_name = 'Crimes (Substituted Section 59) Amendment Bill'
    @asking_mp_id = 789
    @other_asking_mp_id = 321
    @yet_other_asking_mp_id = 321
    @asking_mp_name = 'CHESTER BORROWS (National—Whanganui)'
    @question_text = '<p>Will</p>'
    @answering_mp_id = 245
    @answering_mp_name = 'SUE BRADFORD (Member in charge of the Crimes (Substituted Section 59) Amendment Bill)'
    @answer_text = '<p>Yes.</p>'
    @answer_from_type = Mp
    @about_type_attribute = :member_in_charge
    @about_type = Bill
    @answer_time = '15:15:02'

    @supplimentary_questioners_names = [
      'Chester Borrows',
      'Gordon Copeland',
      'Peter Brown',
      'Peter Brown'
    ]
    @supplimentary_questioners_ids = [
      @asking_mp_id,
      @other_asking_mp_id,
      @yet_other_asking_mp_id,
      @yet_other_asking_mp_id
    ]

    @first_suplimentary_mp_name = 'Chester Borrows'
    @first_suplimentary_mp_id = @asking_mp_id
    @first_suplimentary_question_text = '<p>Does</p>'

    @supplimentary_answerer_name = 'SUE BRADFORD'
    @first_suplimentary_answer_text = '<p>The</p>'

    @first_interjection_index = 4
    @interjecter_names = [
        'Madam SPEAKER',
        'Peter Brown',
        'Madam SPEAKER',
        'Peter Brown',
        'Madam SPEAKER',
        'Peter Brown',
        'Madam SPEAKER',
        'Madam SPEAKER',
        'Gordon Copeland',
        'Peter Brown',
        'Madam SPEAKER',
        'Peter Brown',
        'Madam SPEAKER',
        'Gordon Copeland',
        'Peter Brown',
        'Madam SPEAKER',
        'Peter Brown',
        'Madam SPEAKER'
    ]

    @speaker_id = 202
    @copeland_id = 303
    @brown_id = 404
    @interjecter_ids = [
        @speaker_id,
        @brown_id,
        @speaker_id,
        @brown_id,
        @speaker_id,
        @brown_id,
        @speaker_id,
        @speaker_id,
        @copeland_id,
        @brown_id,
        @speaker_id,
        @brown_id,
        @speaker_id,
        @copeland_id,
        @brown_id,
        @speaker_id,
        @brown_id,
        @speaker_id
    ]
    @interjecter_text = '<p>I</p>'

    HansardParser.stub!(:load_file).and_return html
    parse_debate
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All oral questions"

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - 1. Crimes (Substituted Section 59) Amendment Bill—Reasonable Force Amendment</title>
<meta name="DC.Date" content="2007-03-28T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a><h1>1. Crimes (Substituted Section 59) Amendment Bill—Reasonable Force Amendment</h1>
    <a name="DocumentReference"></a><p>[Volume:638;Page:8408]</p>
    <div class="SubsQuestion">
      <p class="SubsQuestion">
        <strong>1. </strong>
        <strong>CHESTER BORROWS (National—Whanganui)</strong> to the <strong>Member in charge of the Crimes (Substituted Section 59) Amendment Bill</strong>: Will</p>
      <p class="SubsAnswer">
        <a name="time_15:15:02"></a>
        <strong>SUE BRADFORD (Member in charge of the Crimes (Substituted Section 59) Amendment Bill)</strong>
        <strong>:</strong> Yes.</p>
      <p class="SupQuestion"><strong>Chester Borrows</strong>: Does</p>
      <p class="SupAnswer"><strong>SUE BRADFORD</strong>: The</p>
      <p class="Interjection"><strong>Madam SPEAKER</strong>: I</p>
      <p class="Interjection"><strong>Peter Brown</strong>: I</p>
      <p class="Interjection"><strong>Madam SPEAKER</strong>: You</p>
      <p class="Interjection"><strong>Peter Brown</strong>: I</p>
      <p class="Interjection"><strong>Madam SPEAKER</strong>: That</p>
      <p class="Interjection"><strong>Peter Brown</strong>: I</p>
      <p class="Interjection"><strong>Madam SPEAKER</strong>: Leave</p>
      <p class="SupQuestion"><strong>Gordon Copeland</strong>: Will</p>
      <p class="SupAnswer"><strong>SUE BRADFORD</strong>: In</p>
      <a name="page_8409"></a>
      <p class="SupQuestion"><strong>Peter Brown</strong>: How</p>
      <p class="Interjection"><strong>Madam SPEAKER</strong>: Perhaps</p>
      <p class="SupQuestion"><strong>Peter Brown</strong>: During</p>
      <p class="SupAnswer"><strong>SUE BRADFORD</strong>: I</p>
      <p class="Interjection"><strong>Gordon Copeland</strong>: I</p>
      <p class="Interjection"><strong>Peter Brown</strong>: I</p>
      <p class="Interjection"><strong>Madam SPEAKER</strong>: Point</p>
      <p class="Interjection"><strong>Peter Brown</strong>: That</p>
      <p class="Interjection"><strong>Madam SPEAKER</strong>: You</p>
      <p class="Interjection"><strong>Gordon Copeland</strong>: I</p>
      <ul class=""><li>Document, by leave, laid on the Table of the House.</li></ul>
      <p class="Interjection"><strong>Peter Brown</strong>: I</p>
      <p class="Interjection"><strong>Madam SPEAKER</strong>: I</p>
      <p class="Interjection"><strong>Peter Brown</strong>: Am</p>
      <p class="Interjection"><strong>Madam SPEAKER</strong>: That</p>
    </div>
  </div>
</div>
</body>
</html>|
  end
end

describe HansardParser, " when passed question with question number not in strong element" do
  include OralQuestionHelperMethods

  before do
    @name = 'Finance and Expenditure Committee—Television New Zealand Inquiry'
    @file_name = '48HansQ_20060221_00000742-1-Finance-and-Expenditure-Committee-Television.htm'
    @debate_index = 2
    @publication_status = 'F'
    @date = Date.new 2006,2,21
    @oral_answer_no = 1
    @about_id = 123
    @answer_from_id = 456
    @answer_from_name = 'Chairperson of the Finance and Expenditure Committee'
    @asking_mp_id = 789
    @asking_mp_name = 'RODNEY HIDE (Leader—ACT)'
    @question_text = '<p>Does</p>'
    @answering_mp_id = 245
    @answering_mp_name = 'SHANE JONES (Chairperson of the Finance and Expenditure Committee)'
    @answer_text = '<p>Yes.</p>'
    @answer_from_type = CommitteeChair
    @about_type_attribute = :committee
    @about_type = Committee
    @answer_time = '15:24:50'

    @supplimentary_questioners_names = ['Rodney Hide']
    @supplimentary_questioners_ids = [@asking_mp_id]

    @first_suplimentary_mp_name = 'Rodney Hide'
    @first_suplimentary_mp_id = @asking_mp_id
    @first_suplimentary_question_text = '<p>Could</p>'
    @supplimentary_answerer_name = 'SHANE JONES'
    @first_suplimentary_answer_text = '<p>I</p>'
    @interjecter_names = []
    HansardParser.stub!(:load_file).and_return html
    parse_debate
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All oral questions"

  def html
    %Q|<html>
<head>
<title>New Zealand Parliament - 1. Finance and Expenditure Committee—Television New Zealand Inquiry</title>
<meta name="DC.Date" content="2006-02-21T12:00:00.000Z" />
</head>
<body>
<div class="copy">
  <div class="section">
    <a name="DocumentTitle"></a>
    <h1>1. Finance and Expenditure Committee—Television New Zealand Inquiry</h1>
    <a name="DocumentReference"></a>
    <p>[Volume:629;Page:1286]</p>
    <div class="SubsQuestion">
      <p class="SubsQuestion">1.
      <strong>RODNEY HIDE (Leader—ACT)</strong> to the <strong>Chairperson of the Finance and Expenditure Committee</strong>: Does</p>
      <p class="SubsAnswer">
        <a name="time_15:24:50"></a>
        <strong>SHANE JONES (Chairperson of the Finance and Expenditure Committee)</strong>
        <strong>:</strong> Yes.</p>
      <p class="SupQuestion"><strong>Rodney Hide</strong>: Could</p>
      <p class="SupAnswer"><strong>SHANE JONES</strong>: I</p>
      <a name="page_1287"></a>
    </div>
  </div>
</div>
</body>
</html>|
  end
end
