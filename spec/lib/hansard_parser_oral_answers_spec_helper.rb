require File.dirname(__FILE__) + '/hansard_parser_spec_helper'

module OralAnswersHelperMethods

  def parse_oral_answers_all
    if PARSED[@name]
      @url = 'http://www.parliament.nz/en-NZ/PB/Debates/Debates/c/5/7/'+@file_name
      @debate = PARSED[@name]
      @debate
    else
      @ministers.each_with_index do |minister_name, index|
        minister = mock(Minister)
        portfolio = mock(Portfolio)

        Minister.should_receive(:from_name).any_number_of_times.with(minister_name).and_return(minister)
        minister.should_receive(:portfolio).any_number_of_times.and_return(portfolio)

        minister.should_receive(:id).any_number_of_times.and_return(index + 1)
        portfolio.should_receive(:id).any_number_of_times.and_return(index + 1)
      end

      mp = mock(Mp)
      mp.should_receive(:id).any_number_of_times.and_return 42
      mp.stub!(:party).and_return nil
      Mp.stub!(:from_name).and_return(mp)
      debates = parse_hansard @file_name, @debate_index
      debates.each {|d| d.save!}

      if debates.size == 1
        @debate = debates.first
      else
        @debate = debates
      end
      PARSED[@name] = @debate
      @debate
    end
  end
end



describe "All oral questions", :shared => true do
  it_should_behave_like "All debates"

  before(:all) do
    @css_class = 'oralanswer'
    @class = OralAnswer
  end

  it 'should set oral answer number' do
    @debate.oral_answer_no.should == @oral_answer_no
  end

  it 'should have answer from set correctly' do
    @debate.answer_from_type.should == @answer_from_type.name
    @debate.answer_from_id.should == @answer_from_id
  end

  it 'should have about type set correctly' do
    @debate.about_type.should == @about_type.name
    @debate.about_id.should == @about_id
  end

  it 'should have an initial question' do
    question = @debate.contributions.first
    question.should_not be_nil
    question.spoken_in_id.should == @debate.id
    question.should be_an_instance_of(SubsQuestion)
    question.speaker.should == @asking_mp_name
    question.spoken_by_id.should == @asking_mp_id
    question.text.should == @question_text
  end

  it 'should have an initial answer' do
    answer = @debate.contributions[1]
    answer.should_not be_nil
    answer.spoken_in_id.should == @debate.id
    answer.should be_an_instance_of(SubsAnswer)
    answer.speaker.should == @answering_mp_name
    answer.spoken_by_id.should == @answering_mp_id
    answer.text.should == @answer_text
    answer.time.strftime('%H:%M:%S').should == @answer_time
  end

  it 'should have first suplimentary question' do
    question = @debate.contributions[2]
    question.should_not be_nil
    question.spoken_in_id.should == @debate.id
    question.should be_an_instance_of(SupQuestion)
    question.speaker.should == @first_suplimentary_mp_name
    question.spoken_by_id.should == @first_suplimentary_mp_id
    question.text.should == @first_suplimentary_question_text
  end

  it 'should have first suplimentary answer' do
    answer = @debate.contributions[3]
    answer.should_not be_nil
    answer.spoken_in_id.should == @debate.id
    answer.should be_an_instance_of(SupAnswer)
    answer.speaker.should == @supplimentary_answerer_name
    answer.spoken_by_id.should == @answering_mp_id
    answer.text.should == @first_suplimentary_answer_text
  end

  it 'should have first interjection, if any' do
    if @first_interjection_index
      interjection = @debate.contributions[@first_interjection_index]
      interjection.should_not be_nil
      interjection.spoken_in_id.should == @debate.id
      interjection.should be_an_instance_of(Interjection)

      interjection.speaker.should == @interjecter_names.first
      interjection.spoken_by_id.should == @interjecter_ids.first
      interjection.text.should == @interjecter_text
    end
  end

end

module OralQuestionHelperMethods

  def parse_oral_answers name, debate_index
    @url = 'http://www.parliament.nz/en-NZ/PB/Debates/Debates/c/5/7/'+name
    HansardParser.new(File.dirname(__FILE__) + "/../data/#{name}", @url, @date).parse_oral_answer debate_index, nil
  end

  def parse_debate
    if PARSED[@name]
      @url = 'http://www.parliament.nz/en-NZ/PB/Debates/Debates/c/5/7/'+@file_name
      @debate = PARSED[@name]
    else
      answer_about = mock(@about_type)
      answer_from = mock(@answer_from_type)
      answer_about.should_receive(:id).and_return @about_id
      answer_from.should_receive(:id).and_return @answer_from_id

      if @about_type == Bill
        answer_about.should_receive(:member_in_charge).and_return answer_from
        Bill.should_receive(:from_name_and_date).with(@answer_from_name,@date).and_return answer_about
      else
        answer_from.should_receive(@about_type_attribute).and_return answer_about
        @answer_from_type.should_receive(:from_name).with(@answer_from_name).and_return answer_from
      end

      @asking_mp = mock(Mp)
      @asking_mp.stub!(:party).and_return nil
      @asking_mp.should_receive(:id).any_number_of_times.and_return @asking_mp_id
      Mp.should_receive(:from_name).with(@asking_mp_name, @date).and_return @asking_mp

      @answering_mp = mock(Mp)
      @answering_mp.stub!(:party).and_return nil
      @answering_mp.should_receive(:id).any_number_of_times.and_return @answering_mp_id
      Mp.should_receive(:from_name).with(@answering_mp_name, @date).and_return @answering_mp
      Mp.should_receive(:from_name).with(@supplimentary_answerer_name, @date).any_number_of_times.and_return @answering_mp

      @supplimentary_questioners = []
      @supplimentary_questioners_names.each_with_index do |name, index|
        @supplimentary_questioners << mock(Mp)
        @supplimentary_questioners.last.should_receive(:id).any_number_of_times.and_return @supplimentary_questioners_ids[index]
        Mp.should_receive(:from_name).with(name, @date).any_number_of_times.and_return @supplimentary_questioners.last
      end

      @interjecters = []
      @interjecter_names.each_with_index do |name,index|
        @interjecters << mock(Mp)
        @interjecters.last.stub!(:party).and_return nil
        @interjecters.last.should_receive(:id).any_number_of_times.and_return @interjecter_ids[index]
        Mp.should_receive(:from_name).with(name, @date).any_number_of_times.and_return @interjecters.last
      end

      if @interjecter_names.size > 0
        @interjecter = @interjecter_names.first
        @interjecter_id = @interjecter_ids.first
      end
      @oral_answers = parse_oral_answers @file_name, @debate_index-1
      @oral_answers.save!
      @debate = @oral_answers.oral_answers[0]
      PARSED[@name] = @debate
    end
  end
end
