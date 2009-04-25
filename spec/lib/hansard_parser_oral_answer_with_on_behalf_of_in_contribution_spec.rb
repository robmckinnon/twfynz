require File.dirname(__FILE__) + '/hansard_parser_oral_answers_spec_helper'

describe HansardParser, " when passed oral question that has 'on behalf of' in contribution text" do
  include OralQuestionHelperMethods

  before do
    @file_name = 'b.htm'
    @name = 'Electoral Finance Bill—Regulated Period'
    @debate_index = 2
    @publication_status = 'U'
    @date = Date.new 2007,9,5
    @oral_answer_no = 4
    @about_id = 123
    @answer_from_id = 456
    @asking_mp_id = 789
    @other_asking_mp_id = 102
    @yet_other_asking_mp_id = 103
    @asking_mp_name = 'Hon BILL ENGLISH (Deputy Leader—National)'
    @question_text = '<p>When</p>'
    @answering_mp_id = 245
    @answering_mp_name = 'Hon MARK BURTON (Minister of Justice)'
    @answer_text = '<p>1 January.</p>'
    @answer_from_name = 'Minister of Justice'
    @answer_from_type = Minister
    @about_type_attribute = :portfolio
    @about_type = Portfolio
    @answer_time = '14:22:22'

    @supplimentary_questioners_names = [
        'Hon Bill English',
        'Lynne Pillay',
        'Hon Bill English',
        'R Doug Woolerton',
        'Sue Kedgley',
        'Hon Bill English',
        'Hon Bill English',
        'Hon Bill English'
    ]
    @supplimentary_questioners_ids = [
      @asking_mp_id,
      @other_asking_mp_id,
      @asking_mp_id,
      @yet_other_asking_mp_id,
      @yet_other_asking_mp_id,
      @asking_mp_id,
      @asking_mp_id,
      @asking_mp_id
    ]

    @first_suplimentary_mp_name = 'Hon Bill English'
    @first_suplimentary_mp_id = @asking_mp_id
    @first_suplimentary_question_text = '<p>Why</p>'

    @supplimentary_answerer_name = 'Hon MARK BURTON'
    @first_suplimentary_answer_text = '<p>Because</p>'

    @interjecter_names = ['Hon Bill English','Madam SPEAKER']
    @interjecter_ids = [@asking_mp_id, @yet_other_asking_mp_id]
    HansardParser.stub!(:load_file).and_return html
    parse_debate
  end

  after(:all) do
    Debate.find(:all).each {|d| d.destroy}
    PARSED.clear
  end

  it_should_behave_like "All oral questions"

  it 'should set contribution text when text contains "on behalf of"' do
    answer = @debate.contributions[5]
    answer.should_not be_nil
    answer.spoken_in_id.should == @debate.id
    answer.should be_an_instance_of(SupAnswer)
    answer.speaker.should == 'Hon MARK BURTON'
    answer.text.should == '<p>That is a good question, on behalf of the National Party,</p>'
  end

  def html
    %Q|<html>
  <head>
    <title>New Zealand Parliament - 4. Electoral Finance Bill—Regulated Period</title>
    <meta name="DC.Date" content="2007-09-05T12:00:00.000Z" />
  </head>
  <body>
    <div class="copy">
      <div class="section">
        <a name="DocumentTitle"></a>
        <h1>4. Electoral Finance Bill—Regulated Period</h1>
        <a name="DocumentReference"></a>
        <p>[Uncorrected transcript—subject to correction and further editing.]</p>
        <div class="SubsQuestion">
          <p class="SubsQuestion">
            <strong>4. </strong>
            <strong>Hon BILL ENGLISH (Deputy Leader—National)</strong> to the <strong>Minister of Justice</strong>: When</p>
          <p class="SubsAnswer">
            <a name="time_14:22:22"></a>
            <strong>Hon MARK BURTON (Minister of Justice)</strong>
            <strong>:</strong> 1 January.</p>
          <p class="SupQuestion">
            <strong>Hon Bill English</strong>: Why</p>
          <p class="SupAnswer">
            <strong>Hon MARK BURTON</strong>: Because</p>
          <p class="SupQuestion">
            <strong>Lynne Pillay</strong>: What</p>
          <p class="SupAnswer">
            <strong>Hon MARK BURTON</strong>: That is a good question, on behalf of the National Party,</p>
        </div>
      </div>
    </div>
  </body>
</html>|
  end
end
