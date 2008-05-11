require File.dirname(__FILE__) + '/../spec_helper'

def committee_bill_params
  {:bill_name => 'Major Events Management Bill',
        :parliament_url => '2/5/c/25c94892184b4eb3b38f3d4c465e200d.htm',
        :parliament_id => '2/5/c/25c94892184b4eb3b38f3d4c465e200d.htm',
        :introduction => '2006-12-12',
        :mp_name => 'Rod Donald'}
end

describe Committee, "from_name" do

  it 'should find "Finance Committee"' do
    committee = mock Committee
    committee.should_receive(:committee_name).and_return 'Finance'
    Committee.should_receive(:find).with(:all).and_return [committee]

    Committee.from_name("Finance Committee").should eql(committee)
  end

  it 'should find "Māori Affairs Committee"' do
    committee = mock Committee
    committee.should_receive(:committee_name).and_return 'Māori Affairs'
    Committee.should_receive(:find).with(:all).and_return [committee]

    Committee.from_name("Māori Affairs Committee").should eql(committee)
  end

  it 'should find "Maori Affairs Committee"' do
    committee = mock Committee
    committee.should_receive(:committee_name).and_return 'Māori Affairs'
    Committee.should_receive(:find).with(:all).and_return [committee]

    Committee.from_name("Maori Affairs Committee").should eql(committee)
  end

end

describe Committee, 'in general' do

  it 'should have bills' do
    committee = Committee.create :clerk_category_id=>"18", :committee_name => 'Business', :url => 'business', :committee_type => 'SpecialistCommittee'
    Mp.stub!(:from_name).and_return(mock_model(Mp))
    bill = GovernmentBill.create committee_bill_params.merge(:referred_to_committee_id => committee.id)
    committee.bills.size.should == 1
    committee.bills.first.id.should == bill.id

    Committee.delete_all
    Bill.delete_all
  end
end

describe Committee, 'on creation' do

  it 'should have former defaulted to false' do
    committee = Committee.new
    committee.valid?
    committee.former.should be_false
  end

end
