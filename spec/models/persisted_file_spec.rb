require File.dirname(__FILE__) + '/../spec_helper'

describe PersistedFile, 'the class' do

  before(:all) do
    @first_date = Date.new(2007,8,15)
    @second_date = Date.new(2007,8,16)
    @file = PersistedFile.new({:publication_status => 'U',
        :debate_date => @first_date,
        :file_name => '2007/08/15/uncorrected/48HansQ_20070815_00000071-1-Electoral-Finance-Bill-Select-Committee.htm'})
    @second_file = PersistedFile.new({:publication_status => 'U',
        :debate_date => @second_date,
        :file_name => '2007/08/16/uncorrected/48HansQ_20070816_00000035-1-Air-New-Zealand-Charter-Flights.htm'})
    @file.save!
    @second_file.save!
  end

  after(:all) do
    PersistedFile.delete_all
  end

  it 'should return unpersisted_dates correctly' do
    dates = PersistedFile.unpersisted_dates('U')
    dates[0].to_s.should == @first_date.to_s
    dates[1].to_s.should == @second_date.to_s
  end

  it 'should return unpersisted file names for a date' do
    files = PersistedFile.unpersisted_files(@first_date, 'U')
    files[0].should == @file
  end

end
