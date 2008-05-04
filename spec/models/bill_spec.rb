require File.dirname(__FILE__) + '/../spec_helper'

def bill_params
  {:bill_name => 'Major Events Management Bill',
        :parliament_url => '2/5/c/25c94892184b4eb3b38f3d4c465e200d.htm',
        :introduction => '2006-12-12',
        :mp_name => 'Rod Donald',
        :parliament_id => ''}
end

def new_bill params=nil
  Mp.should_receive(:from_name).any_number_of_times.and_return(mock_model(Mp))
  bill = Bill.new(params ? bill_params.merge(params) : bill_params)
  bill.should be_valid
  bill.type = 'Bill'
  bill
end

def bill_invalid_without param
  params = bill_params; params.delete(param)
  Mp.should_receive(:from_name).and_return(mock_model(Mp))
  bill = Bill.new(params)
  bill.should_not be_valid
end

describe Bill, 'finding by plain bill name and year' do
  before(:all) do
    @bill = new_bill bill_params
    @bill.save
    @other_bill = new_bill bill_params.merge(:introduction => '2005-12-12')
    @other_bill.save
  end

  after(:all) do
    Bill.delete_all
  end

  it 'should return bill if plain name and introduction year match' do
    bills = Bill.find_all_by_plain_bill_name_and_year(bill_params[:bill_name], 2006)
    bills.should == [@bill]
  end

end

describe Bill, 'the class' do

  it 'should respond to find_by_bill_name' do
    Bill.find_by_bill_name('').should be_nil
  end
end

describe Bill, 'with introduction date' do

  it 'should have date of earliest recorded activity equal to introduction date' do
    bill = new_bill
    date = bill_params[:introduction]
    bill.earliest_date.to_s.should eql(date)
  end
end

describe Bill, 'with first reading negatived' do

  it 'should have first reading negatived' do
    bill = new_bill(:first_reading_negatived => true)
    bill.first_reading_negatived.should be_true
  end

  it 'should not be current' do
    bill = new_bill(:first_reading_negatived => true)
    bill.current?.should be_false
  end
end

describe Bill, 'unique url identifier' do

  it 'should be generated on create if none exists' do
    bill = new_bill :bill_name => 'Social Security (Long-term Residential Care) Amendment Bill'
    bill.url.should_not be_nil
    bill.url.should eql('social_security_long-term_residential')
  end

  it 'should be generated on create if none exists, and other bill has same bill name' do
    Bill.should_receive(:find_by_url).
        with('social_security_long-term_residential').
        and_return(mock_model(Bill))

    bill = new_bill(:introduction => '2006-05-09',
        :bill_name => 'Social Security (Long-term Residential Care) Amendment Bill')

    bill.url.should_not be_nil
    bill.url.should eql('social_security_long-term_residential_2006')
  end

  it 'should replace unicode characters with latin equivalents' do
    bill = new_bill bill_params.merge(:bill_name => 'New Zealand Geographic Board (Ngā Pou Taunaha o Aotearoa) Bill')
    bill.url.should == 'nz_geographic_board_nga_pou_taunaha_o'
  end

  it 'should be left unchanged on create if one exists' do
    bill = new_bill(
        :bill_name => 'Crimes (Substituted Section 59) Amendment Bill',
        :former_name => 'Crimes (Abolition of Force as a Justification for Child Discipline) Amendment Bill',
        :introduction => '2003-12-15',
        :url => 'crimes_abolition_of_force_justification')

    bill.url.should eql('crimes_abolition_of_force_justification')
  end
end

describe Bill, "on creation" do

  it 'should be valid with valid attributes' do
    bill = new_bill
  end

  it 'should be invalid without a bill_name' do
    bill_invalid_without :bill_name
  end

  it 'should be invalid without a parliament_url' do
    bill_invalid_without :parliament_url
  end

  it 'should be invalid without date of earliest recorded activity' do
    bill_invalid_without :introduction
  end

  it "should, if it doesn't have an earliest date and bill is formerly part of other bill, have earliest date set to formerly part of bill's earliest date" do
    former_bill = mock_model(Bill)
    former_bill.stub!(:id).and_return(1)
    former_bill.should_receive(:earliest_date).and_return Date.new(2007,9,11)
    Bill.should_receive(:find_by_bill_name).with('Aviation Security Legislation Bill').and_return former_bill
    Bill.should_receive(:find).with(1).and_return former_bill
    Mp.should_receive(:from_name).and_return(mock_model(Mp))
    bill = Bill.new(bill_params.merge(:introduction => nil, :bill_change => '(Formerly part of Aviation Security Legislation Bill)'))
    bill.should be_valid
    bill.earliest_date.should == Date.new(2007,9,11)
  end

  it 'should be invalid if introduced by MP is not a known MP' do
    bill = Bill.new(bill_params.merge(:mp_name => 'Red Herring'))
    lambda { bill.valid? }.should raise_error(Exception, /Validation failed/)
  end

  it 'should have first and second reading negatived defaulted to false' do
    bill = new_bill
    bill.first_reading_negatived.should be_false
    bill.second_reading_negatived.should be_false
  end

  it 'should have a member in charge' do
    bill = Bill.new(bill_params.merge(:member_in_charge_id=>1))
    mp = mock_model Mp
    Mp.should_receive(:find).with(1, anything).and_return mp

    bill.member_in_charge.should eql(mp)
  end

  it 'should be current' do
    bill = new_bill
    bill.current?.should be_true
  end

  it 'should have plain bill name set to be bill name without parentheses, without dashes, without single quotes' do
    bill = new_bill :bill_name => 'Social Security (Long-term Residential Care) Amendment Bill'
    bill.plain_bill_name.should == 'Social Security Longterm Residential Care Amendment Bill'
    bill = new_bill :bill_name => 'Companies (Minority Buy-out Rights) Amendment Bill'
    bill.plain_bill_name.should == 'Companies Minority Buyout Rights Amendment Bill'
    bill = new_bill :bill_name => "Copyright (New Technologies and Performers' Rights) Amendment Bill"
    bill.plain_bill_name.should == 'Copyright New Technologies and Performers Rights Amendment Bill'
  end
end


describe Bill, "on creation when referred_to is present" do

  it 'should populate committee' do
    id = 123
    committee = mock_model(Committee)
    committee.should_receive(:id).and_return(id)
    Committee.should_receive(:from_name).with("Finance Committee").and_return(committee)

    bill = new_bill :referred_to => 'Finance Committee'

    bill.referred_to_committee_id.should eql(id)
  end

  it 'should raise error if committee not found' do
    bill = Bill.new(bill_params.merge(:referred_to => 'Silly Committee'))
    Committee.should_receive(:from_name).with("Silly Committee").and_return(nil)

    lambda { bill.valid? }.should raise_error(Exception, /Validation failed/)
  end
end

describe Bill, 'when referred to committee' do

  it 'should have a referred to committee' do
    bill = Bill.new(bill_params.merge(:referred_to_committee_id=>1))
    committee = mock_model Committee
    Committee.should_receive(:find).with(1, anything).and_return committee

    bill.referred_to_committee.should eql(committee)
  end
end

describe Bill, "on creation when bill_change specifies former name" do

  it 'should populate former name' do
    bill = new_bill :bill_change => '(Formerly Commissioner for Children Bill)'

    bill.former_name.should eql('Commissioner for Children Bill')
  end

end


describe Bill, "on creation when bill_change specifies formerly part of" do

  it 'should populate formerly part of bill' do
    id = 123
    former_bill = Bill.new(bill_params.merge(:bill_name => 'Statutes Amendment Bill (No 2)'))
    former_bill.should_receive(:id).and_return(id)

    Bill.should_receive(:find_by_bill_name).with('Statutes Amendment Bill (No 2)').and_return(former_bill)

    bill = new_bill :bill_change => '(Formerly part of Statutes Amendment Bill (No 2))'

    bill.formerly_part_of_id.should == id
  end

  it 'should raise error if bill not found' do
    bill = Bill.new(bill_params.merge(:bill_change => '(Formerly part of Silly Bill)'))

    Bill.should_receive(:find_by_bill_name).with('Silly Bill').and_return(nil)

    lambda { bill.valid? }.should raise_error(Exception, /Validation failed/)
  end
end

describe Bill, 'when formerly part of another bill' do

  it 'should have reference to former part of bill' do
    id = 123
    former_bill = Bill.new(bill_params.merge(:bill_name => 'Statutes Amendment Bill (No 2)'))
    Bill.should_receive(:find).with(id, anything).and_return former_bill

    bill = new_bill :formerly_part_of_id => id
    bill.formerly_part_of.should == former_bill
  end
end

describe Bill, 'when divided into other bills' do

  it 'should have reference to divided into bills' do
    Mp.should_receive(:from_name).twice.and_return(mock_model(Mp))

    former_bill = Bill.new bill_params.merge(:bill_name => 'Statutes Amendment Bill (No 2)')
    former_bill.type = 'Bill'
    former_bill.save!
    bill = Bill.new bill_params.merge(:formerly_part_of_id => former_bill.id)
    bill.type = 'Bill'
    bill.save!

    former_bill.divided_into_bills.first.should eql(bill)

    Bill.delete_all
  end
end

describe Bill, "on update" do
  it 'should raise error if committee not found when referred_to is present' do
    bill = Bill.new(bill_params)
    bill.type = 'Bill'
    Mp.should_receive(:from_name).and_return(mock_model(Mp))
    bill.save!

    bill.attributes= bill_params.merge(:referred_to => 'Finance Committee')
    id = 123
    committee = mock_model(Committee)
    committee.should_receive(:id).and_return(id)
    Committee.should_receive(:from_name).with("Finance Committee").and_return(committee)

    bill.should be_valid
    bill.referred_to_committee_id.should eql(id)

    Bill.delete_all
  end
end

describe Bill, 'getting NzlEvents' do
  fixtures :bills, :nzl_events

  it 'should should return associated NzlEvents latest first' do
    titles = bills(:a_bill).nzl_events.collect(&:title)
    titles.include?(nzl_events(:two).title).should be_true
    titles.include?(nzl_events(:one).title).should be_true
  end
end
