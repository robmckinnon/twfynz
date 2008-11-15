require File.dirname(__FILE__) + '/../spec_helper'

describe Member do

  assert_model_belongs_to :parliament
  assert_model_belongs_to :party
  assert_model_belongs_to :person
  assert_model_belongs_to :replaced_by

  describe 'when determing if active on date' do
    it 'should return false if given date is less than from_date' do
      date = Date.parse('2007-01-01')
      member = Member.new :from_date => date+1
      member.is_active_on(date).should be_false
    end

    it 'should return true if given date is equal to from_date' do
      date = Date.parse('2007-01-01')
      member = Member.new :from_date => date
      member.is_active_on(date).should be_true
    end

    it 'should return true if given date is equal to to_date' do
      date = Date.parse('2007-01-01')
      member = Member.new :from_date => date-1, :to_date => date
      member.is_active_on(date).should be_true
    end

    it 'should return false if given date is greater than to to_date' do
      date = Date.parse('2007-01-01')
      member = Member.new :from_date => date-2, :to_date => date-1
      member.is_active_on(date).should be_false
    end

    it 'should return true if given date is greater than from_date and to_date is nil' do
      date = Date.parse('2007-01-01')
      member = Member.new :from_date => date-1
      member.is_active_on(date).should be_true
    end

    it 'should return true if given date is greater than from_date and less than to_date' do
      date = Date.parse('2007-01-01')
      member = Member.new :from_date => date-1, :to_date => date+1
      member.is_active_on(date).should be_true
    end

    it 'should return false if from_date and to_date are both nil' do
      date = mock('date')
      member = Member.new
      member.is_active_on(date).should be_false
    end
  end

  describe 'when member has urls' do
    it 'should determine date from members sworn url' do
      member = Member.new :members_sworn_url => 'http://theyworkforyou.co.nz/members_sworn/2008/mar/04'
      member.members_sworn_date.should == Date.new(2008,3,4)
    end

    it 'should determine date from maiden statement url' do
      member = Member.new :maiden_statement_url => 'http://theyworkforyou.co.nz/maiden_statement/2008/mar/04'
      member.maiden_statement_date.should == Date.new(2008,3,4)
    end
    it 'should determine date from resignation_url' do
      member = Member.new :resignation_url => 'http://theyworkforyou.co.nz/resignation/2008/mar/04'
      member.resignation_date.should == Date.new(2008,3,4)
    end
    it 'should determine date from valedictory_statement_url' do
      member = Member.new :valedictory_statement_url => 'http://theyworkforyou.co.nz/valedictory_statement/2008/mar/04'
      member.valedictory_statement_date.should == Date.new(2008,3,4)
    end
  end
end
