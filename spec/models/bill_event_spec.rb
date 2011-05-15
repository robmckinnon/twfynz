require File.dirname(__FILE__) + '/../spec_helper'

describe BillEvent do

  assert_model_belongs_to :bill

  describe 'when creating from NzlEvent' do
    before do
      @bill_id = 123
      @stage = 'introduction'
      @date = Date.new(2007,12,4)
      @source_id = 18
      @nzl_event = mock(NzlEvent, :about_type=>'Bill', :about_id=>@bill_id, :version_stage=> @stage, :version_date=> @date, :id=>@source_id )
      @event = BillEvent.create_from_nzl_event(@nzl_event)
    end

    it 'should set bill id correctly' do
      @event.bill_id.should == @bill_id
    end
    it 'should set name correctly' do
      @event.name.should == @stage
    end
    it 'should set date correctly' do
      @event.date.should == @date
    end
    it 'should set source_type correctly' do
      @event.source_type.should == 'NzlEvent'
    end
    it 'should set source_id correctly' do
      @event.source_id.should == @source_id
    end

    describe 'and asked to set created_at and updated_at date to event date' do
      it 'should set created at date and updated at date to event date' do
        @event.set_created_and_updated_at_date_to_event_date
        @event.created_at.should == @date.to_time.at_beginning_of_day
        @event.updated_at.should == @date.to_time.at_beginning_of_day
      end
    end
  end

  describe 'when creating from a Bill' do
    before do
      @event1 = "Third Reading"
      @event2 = "Royal Assent"
      @date1 = Date.new(2003,10,16)
      @date2 = Date.new(2003,10,21)
      @bill = mock(Bill, :id=> 123,
          :events_by_date => [[@date1, @event1], [@date2, @event2]],
          :debates_in_groups_by_name => [],
          :debates => [])
      @events = BillEvent.create_from_bill(@bill)
    end

    it 'should create a bill event for each bill stage' do
      @events.size.should == 2
    end

    it 'should set name correctly' do
      @events[0].name.should == @event1
      @events[1].name.should == @event2
    end

    it 'should set date correctly' do
      @events[0].date.should == @date1
      @events[1].date.should == @date2
    end

    it 'should set source_type' do
      @events[0].source_type.should be_nil
    end

    it 'should set source_id' do
      @events[0].source_id.should be_nil
    end
  end

  describe 'when comparing to another BillEvent' do
    describe 'and the date is the same on both' do
      before do
        date = Date.new(2008,7,20)
        @first = BillEvent.new :name => 'First Reading', :date => date
        @second = BillEvent.new :name => 'Second Reading', :date => date
        @third = BillEvent.new :name => 'Third Reading', :date => date
      end
      it 'should list First Reading before Second Reading' do
        [@first, @second].sort.should == [@first, @second]
        [@second, @first].sort.should == [@first, @second]
      end
      it 'should list First Reading before Third Reading' do
        [@first, @third].sort.should == [@first, @third]
        [@third, @first].sort.should == [@first, @third]
      end
      it 'should list Second Reading before Third Reading' do
        [@second, @third].sort.should == [@second, @third]
        [@third, @second].sort.should == [@second, @third]
      end
    end
  end
end
