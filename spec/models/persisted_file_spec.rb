require File.dirname(__FILE__) + '/../spec_helper'

describe PersistedFile, 'the class' do

  before(:all) do
    @first_date = Date.new(2007,8,15)
    @second_date = Date.new(2007,8,16)
    @file_name = '2007/08/15/uncorrected/48HansQ_20070815_00000071-1-Electoral-Finance-Bill-Select-Committee.htm'

    @file = PersistedFile.new({:publication_status => 'U',
        :debate_date => @first_date,
        :file_name => @file_name})
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

  it 'should set indexes on date for a given date' do
    download_file = PersistedFile.data_path + @file_name
    storage_file = PersistedFile.storage_path + '2007/08/15/Q/001_Electoral-Finance-Bill-Select-Committee.htm'

    File.should_receive(:size?).and_return 2
    FileUtils.should_receive(:mkdir_p).with(storage_file.sub('/001_Electoral-Finance-Bill-Select-Committee.htm',''))
    FileUtils.should_receive(:cp).with(download_file, storage_file)
    FileUtils.should_receive(:rm).with(download_file)
    FileUtils.should_receive(:touch).with(download_file)
    PersistedFile.should_receive(:strip_empty_lines)
    PersistedFile.should_receive(:set_yaml_index)

    PersistedFile.set_indexes_on_date @first_date, 'U'
    file = PersistedFile.find(@file.id)
    file.index_on_date.should == 1
  end

  it 'should return normalized name correctly for oral question' do
    name = '2007/08/15/uncorrected/48HansQ_20070815_00000071-1-Electoral-Finance-Bill-Select-Committee.htm'
    file = PersistedFile.new :file_name => name, :index_on_date => 1
    file.populate_name
    file.name.should == '2007/08/15/Q/001_Electoral-Finance-Bill-Select-Committee.htm'
  end

  it 'should return normalized name correctly for debate' do
    name = '2008/12/11/advance/49HansD_20081211_00000896-Employment-Relations-Amendment-Bill-Second.htm'
    file = PersistedFile.new :file_name => name, :index_on_date => 8
    file.populate_name
    file.name.should == '2008/12/11/D/008_Employment-Relations-Amendment-Bill-Second.htm'
  end
=begin
  it 'should return normalized name' do
    PersistedFiles.set_normalized_names @first_date
    @file.normalized_name.should == '2007/08/15/001_Electoral-Finance-Bill-Select-Committee.htm'
=end
end
