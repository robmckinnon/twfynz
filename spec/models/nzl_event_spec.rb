require File.dirname(__FILE__) + '/../spec_helper'

describe "An NzlEvent", :shared => true do

  before(:all) do
    if @bill_id
      bill = mock_model(Bill)
      bill.stub!(:id).and_return @bill_id
      bill.stub!(:expire_cached_pages)
      Bill.stub!(:find_all_by_plain_bill_name_and_year).and_return [bill]
    end
    if @committee_id
      committee = mock_model(Committee)
      committee.stub!(:id).and_return @committee_id
      Committee.stub!(:from_name).and_return committee
    end
    @nzl_event = NzlEvent.new :title => @title,
        :description => @description,
        :link => @link,
        :pub_date => @pub_date
    @nzl_event.valid?
  end

  it 'should have title set correctly' do
    @nzl_event.title.should == @title
  end

  it 'should have status set correctly' do
    @nzl_event.status.should == @status.downcase
  end

  it 'should have nzl_id set correctly' do
    @nzl_event.nzl_id.should == @nzl_id
  end

  it 'should have version_stage set correctly' do
    @nzl_event.version_stage.should == @version_stage.downcase if @version_stage
  end

  it 'should have version_committee set correctly' do
    @nzl_event.version_committee.should == @committee_name
  end

  it 'should have information_type set correctly' do
    @nzl_event.information_type.should == @information_type
  end

  it 'should have legislation_type set correctly' do
    @nzl_event.legislation_type.should == @legislation_type
  end

  it 'should have year set correctly' do
    @nzl_event.year.should == @year
  end

  it 'should have no set correctly' do
    @nzl_event.no.should == @no
  end

  it 'should have link set correctly' do
    @nzl_event.link.should == @link
  end

  it 'should have committee id set correctly' do
    @nzl_event.committee_id.should == @committee_id
  end

  it 'should have about type set correctly' do
    @nzl_event.about_type.should == @about_type
  end

  it 'should have about id set correctly' do
    @nzl_event.about_id.should == @about_id
  end

  it 'should have version_date set correctly' do
    @nzl_event.version_date.should == @version_date_as_date
  end

  it 'should have current_as_at_date set correctly' do
    @nzl_event.current_as_at_date.should == @current_as_at_date_as_date
  end
end

describe NzlEvent, 'on creation from feed data for a reported bill' do
  before(:all) do
    @title = 'Children Young Persons and Their Families Amendment Bill No 4'
    @bill_id = 123
    @committee_id = 234
    @link = 'http://legislation.govt.nz/bill/government/2004/0159-2/latest/contents.html'
    @no = '159-2'
    @nzl_id = 'bill/government/2004/0159-2/latest'
    @information_type = 'bill'
    @legislation_type = 'government'
    @year = 2004
    @committee_name = 'Social Services Committee'
    @status = 'Modified'
    @version_stage = 'Reported'
    @version_date = '15 November 2004'
    @version_date_as_date = Date.new(2004,11,15)
    @current_as_at_date = nil
    @current_as_at_date_as_date = nil
    @pub_date = 'Mon, 07 Jan 2008 01:00:00 NZST'
    @pub_date_expected = [2008, 1, 7, 1, 0]
    @about_type = 'Bill'
    @about_id = @bill_id

    @description = %Q[Status: #{@status}&lt;br /&gt;
ID: #{@nzl_id}&lt;br /&gt;
Version: #{@version_stage} from the #{@committee_name}
                    on #{@version_date}&lt;br /&gt;
Information type: #{@information_type}&lt;br /&gt;
Legislation type: #{@legislation_type}&lt;br /&gt;
Year: #{@year}&lt;br /&gt;
No: #{@no}]
  end

  it_should_behave_like "An NzlEvent"
end

describe NzlEvent, 'on creation from feed data for a new Regulation' do

  before(:all) do
    @title = 'Securities Act Fonterra Cooperative Group Limited Exemption Notice 2003'
    @link = 'http://legislation.govt.nz/regulation/public/2003/0397/latest/contents.html'
    @no = '397'
    @nzl_id = 'regulation/public/2003/0397/latest'
    @information_type = 'regulation'
    @legislation_type = 'public'
    @year = 2003
    @committee_name = nil
    @status = 'New'
    @current_as_at_date = '21/09/2007'
    @current_as_at_date_as_date = Date.new(2007,9,21)
    @pub_date = 'Tue, 08 Jan 2008 14:16:00 NZST'
    @pub_date_expected = [2008, 1, 4, 14, 16]

    @description = %Q[Status: #{@status}&lt;br /&gt;
ID: #{@nzl_id}&lt;br /&gt;
Information type: #{@information_type}&lt;br /&gt;
Legislation type: #{@legislation_type}&lt;br /&gt;
Year: #{@year}&lt;br /&gt;
No: #{@no}&lt;br /&gt;
Current as at date: #{@current_as_at_date}]
  end

  it_should_behave_like "An NzlEvent"
end

describe NzlEvent, 'on creation from feed data for a modified Act' do

  before(:all) do
    @title = 'Electricity Act 1992'
    @link = 'http://legislation.govt.nz/act/public/1992/0122/latest/contents.html'
    @no = '122'
    @nzl_id = 'act/public/1992/0122/latest'
    @information_type = 'act'
    @legislation_type = 'public'
    @year = 1992
    @committee_name = nil
    @status = 'Modified'
    @current_as_at_date = '20/09/2007'
    @current_as_at_date_as_date = Date.new(2007,9,20)
    @pub_date = 'Tue, 08 Jan 2008 01:00:00 NZST'
    @pub_date_expected = [2008, 1, 4, 1, 0]

    @description = %Q[Status: #{@status}&lt;br /&gt;
ID: #{@nzl_id}&lt;br /&gt;
Information type: #{@information_type}&lt;br /&gt;
Legislation type: #{@legislation_type}&lt;br /&gt;
Year: #{@year}&lt;br /&gt;
No: #{@no}&lt;br /&gt;
Current as at date: #{@current_as_at_date}]
  end

  it_should_behave_like "An NzlEvent"
end

def example_nzl_event_data
  {:title => 'Police Amendment Bill',
      :description => 'Status: Modified&lt;br /&gt;
ID: bill/government/2001/0145-1/latest&lt;br /&gt;
Version: Introduction 31 July 2001&lt;br /&gt;
Information type: bill&lt;br /&gt;
Legislation type: government&lt;br /&gt;
Year: 2001&lt;br /&gt;
No: 145-1',
      :link => 'http://legislation.govt.nz/bill/government/2001/0145-1/latest/contents.html',
      :pub_date => 'Fri, 04 Jan 2008 01:00:00 NZST'}
end

describe NzlEvent, 'on creation from feed data when two Bills match' do

  it 'should raise exception when two bills match' do
    bill = mock_model(Bill)
    other_bill = mock_model(Bill)
    Bill.stub!(:find_all_by_plain_bill_name_and_year).and_return [bill, other_bill]

    nzl_event = NzlEvent.new example_nzl_event_data
    lambda { nzl_event.valid? }.should raise_error(Exception, /more than one matching bill/)
  end
end

describe NzlEvent, 'on creation from feed data for a modified Bill' do
  before(:all) do
    @title = 'Police Amendment Bill No 2'
    @bill_id = 123
    @link = 'http://legislation.govt.nz/bill/government/2001/0145-1/latest/contents.html'
    @no = '145-1'
    @nzl_id = 'bill/government/2001/0145-1/latest'
    @information_type = 'bill'
    @legislation_type = 'government'
    @year = 2001
    @committee_name = nil
    @status = 'Modified'
    @version_stage = 'Introduction'
    @version_date = '31 July 2001'
    @version_date_as_date = Date.new(2001,07,31)
    @current_as_at_date = nil
    @current_as_at_date_as_date = nil
    @pub_date = 'Fri, 04 Jan 2008 01:00:00 NZST'
    @pub_date_expected = [2008, 1, 4, 1, 0]
    @about_type = 'Bill'
    @about_id = @bill_id

    @description = %Q[Status: #{@status}&lt;br /&gt;
ID: #{@nzl_id}&lt;br /&gt;
Version: #{@version_stage} #{@version_date}&lt;br /&gt;
Information type: #{@information_type}&lt;br /&gt;
Legislation type: #{@legislation_type}&lt;br /&gt;
Year: #{@year}&lt;br /&gt;
No: #{@no}]
  end

  it_should_behave_like "An NzlEvent"
end

describe NzlEvent, 'creating using create_from method' do

  it 'should create new NzlEvent if there is no matching NzlEvent all attributes the same' do
    data = example_nzl_event_data
    event = mock_model(NzlEvent)
    date = Time.parse('Fri, 04 Jan 2008 01:00:00')
    NzlEvent.should_receive(:parse_pub_date).with(example_nzl_event_data[:pub_date]).and_return date
    NzlEvent.should_receive(:find_all_by_title).with(example_nzl_event_data[:title]).and_return []
    NzlEvent.should_receive(:create).with(data).and_return event
    NzlEvent.create_from(data).should == event
  end

  it 'should not create a new NzlEvent if there is a matching NzlEvent with all attributes the same' do
    data = example_nzl_event_data
    existing = mock_model(NzlEvent)
    existing.stub!(:attributes).and_return :title => 'The Same'

    event = mock_model(NzlEvent)
    event.stub!(:attributes).and_return :title => 'The Same'
    event.should_receive(:valid?).and_return true

    NzlEvent.should_receive(:find_all_by_title).with(data[:title]).and_return [existing]
    NzlEvent.should_receive(:new).with(example_nzl_event_data).and_return event

    NzlEvent.create_from(data).should == nil
  end

  it 'should create a new NzlEvent if othere NzlEvents with matching title have different attributes' do
    data = example_nzl_event_data
    existing = mock_model(NzlEvent)
    existing.stub!(:attributes).and_return :title => 'The Same', :link => 'Old'

    event = mock_model(NzlEvent)
    event.stub!(:attributes).and_return :title => 'The Same', :link => 'Not the same'
    event.should_receive(:valid?).and_return true
    event.should_receive(:save!)

    NzlEvent.should_receive(:find_all_by_title).with(data[:title]).and_return [existing]
    NzlEvent.should_receive(:new).with(example_nzl_event_data).and_return event

    NzlEvent.create_from(data).should == event
  end

end
