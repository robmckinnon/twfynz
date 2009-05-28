require File.dirname(__FILE__) + '/../spec_helper'

PARSED = {} unless defined?(PARSED)

def parse_hansard name, debate_index
  @url = 'http://www.parliament.nz/en-NZ/PB/Debates/Debates/c/5/7/'+name
  HansardParser.new(File.dirname(__FILE__) + "/../data/#{name}", @url, @date).parse debate_index
end

module ParserHelperMethods
  def parse_hansards
    @url = 'http://www.parliament.nz/en-NZ/PB/Debates/Debates/c/5/7/'+@file_name
    HansardParser.new(File.dirname(__FILE__) + "/../data/#{@file_name}", @url, @date).parse @debate_index
  end

  def def_party name, id
    party = mock(Party)
    party.should_receive(:id).any_number_of_times.and_return id
    party.should_receive(:vote_name).any_number_of_times.and_return name
    Party.should_receive(:from_vote_name).with(name).any_number_of_times.and_return(party)
    Party.should_receive(:find).with(id, {:select=>nil, :conditions=>nil, :readonly=>nil, :include=>nil}).any_number_of_times.and_return(party)
    party.stub!(:new_record?).and_return false
    party
  end

  def def_parties
    @labour = def_party 'New Zealand Labour', 1
    @nz_first = def_party 'New Zealand First', 2
    @uf = def_party 'United Future', 3
    @progressive = def_party 'Progressive', 4
    @national = def_party 'New Zealand National', 5
    @act = def_party 'ACT New Zealand', 6
    @greens = def_party 'Green Party', 7
    @maori = def_party 'Māori Party', 8
    @independent = def_party 'Independent', 9
  end

  def parse_debate
    if PARSED[@file_name]
      @url = 'http://www.parliament.nz/en-NZ/PB/Debates/Debates/c/5/7/'+@file_name
      @debate = PARSED[@file_name]
    else
      if @bill_id
        @bill = mock(Bill)
        @bill.stub!(:id).and_return @bill_id
        @first_bill_name = @name unless @first_bill_name
        Bill.should_receive(:from_name_and_date).with(@first_bill_name, @date).any_number_of_times.and_return(@bill)
      end
      if @bill_id2
        @bill2 = mock(Bill)
        @bill2.stub!(:id).and_return @bill_id2
        Bill.should_receive(:from_name_and_date).with(@second_bill_name, @date).any_number_of_times.and_return(@bill2)
      end
      if @bill_id3
        @bill3 = mock(Bill)
        @bill3.stub!(:id).and_return @bill_id3
        Bill.should_receive(:from_name_and_date).with(@third_bill_name, @date).any_number_of_times.and_return(@bill3)
      end

      SubDebate.should_receive(:find_all_by_date_and_about_id).any_number_of_times.and_return([])
      @mp = mock(Mp)
      @mp.stub!(:party).and_return nil
      @mp.stub!(:id).and_return 123
      Mp.stub!(:from_name).and_return @mp
      Mp.stub!(:from_vote_name).and_return @mp

      @debate = parse_hansards
      @debate.stub!(:has_bill?).and_return false
      @debate.save!
      PARSED[@file_name] = @debate
    end
  end
end

describe "All debates", :shared => true do
  it 'should create debate with correct type' do
    @debate.should be_an_instance_of(@class)
  end

  it 'should set debate index' do
    @debate.debate_index.should == @debate_index
  end

  it 'should set debate name' do
    @debate.name.should == @name
  end

  it 'should set debate date' do
    @debate.date.to_s.should == @date.to_s
  end

  it 'should set publication status' do
    @debate.publication_status.should == @publication_status
  end

  it 'should set css_class' do
    @debate.css_class.should == @css_class
  end

  it 'should set source_url' do
    @debate.source_url.should == @url
  end

end


describe "All alone debates", :shared => true do
  it_should_behave_like "All debates"

  before(:all) do
    @css_class = 'debatealone'
    @class = DebateAlone
  end
end

describe "All bill debates", :shared => true do
  it_should_behave_like "All debates"

  it 'should create ParentDebate with SubDebate' do
    @debate.should be_a_kind_of(ParentDebate)
    @sub_debate.should be_an_instance_of(SubDebate)
  end

end

describe "All parent debates", :shared => true do
  it_should_behave_like "All debates"

  it 'should create ParentDebate with SubDebate' do
    @debate.should be_a_kind_of(ParentDebate)
    # @sub_debate.should be_an_instance_of(SubDebate)
  end

  it 'should set sub debate name' do
    @sub_debate.name.should == @sub_name
  end

  it 'should set sub debate index' do
    @sub_debate.debate_index.should == @debate_index+1
  end

  it 'should set sub debate date' do
    @sub_debate.date.to_s.should == @date.to_s
  end

  it 'should set subdebate css_class' do
    @sub_debate.css_class.should == 'subdebate'
  end

  it 'should set publication status on sub debate' do
    @sub_debate.publication_status.should == @publication_status
  end
end
