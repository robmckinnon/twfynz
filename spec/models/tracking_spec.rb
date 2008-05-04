require File.dirname(__FILE__) + '/../spec_helper'

describe Tracking, 'from_user_and_item' do
  fixtures :trackings
  fixtures :bills
  fixtures :users

  it 'should retrieve tracking given user and bill' do
    user = users(:the_bob)
    bill = bills(:a_bill)
    bill.class.name.should == 'GovernmentBill'
    Tracking.from_user_and_item(user, bill).should_not be_nil
  end

end

describe Tracking, 'on creation' do
  fixtures :users
  fixtures :bills

  after do
    Tracking.delete_all
  end

  def create_new
    Tracking.new :user_id => users(:the_bob).id,
      :item_id => bills(:a_bill).id,
      :item_type => 'Bill'
  end

  it 'should have tracking_on defaulted to false' do
    tracking = create_new
    tracking.valid?.should be_true
    tracking.tracking_on.should be_false
  end

  it 'should have email_alert defaulted to false' do
    tracking = create_new
    tracking.valid?.should be_true
    tracking.email_alert.should be_false
  end

  it 'should have include_in_feed defaulted to false' do
    tracking = create_new
    tracking.valid?.should be_true
    tracking.include_in_feed.should be_false
  end

  it 'should have created at set automatically' do
    tracking = create_new
    tracking.save.should be_true
    tracking.created_at.should_not be_nil
  end

  it 'should have item set from item id and type' do
    tracking = create_new
    tracking.save.should be_true
    tracking.item.should_not be_nil
  end

  it 'should have user set from user id' do
    tracking = create_new
    tracking.save.should be_true
    tracking.user.should_not be_nil
  end

  it 'should be invalid without user id' do
    tracking = Tracking.new :item_id => bills(:a_bill).id,
      :item_type => 'Bill'
    tracking.save.should be_false
    tracking.errors.invalid?('user').should be_true
  end

  it 'should be invalid without item id' do
    tracking = Tracking.new :user_id => users(:the_bob).id,
      :item_type => 'Bill'
    tracking.save.should be_false
    tracking.errors.invalid?('item').should be_true
  end

  it 'should set item id and type from item' do
    tracking = Tracking.new :user_id => users(:the_bob).id
    tracking.item = bills(:a_bill)
    tracking.save.should be_true
    tracking.item_id.should == bills(:a_bill).id
    tracking.item_type.should == 'Bill'
  end
end

describe Tracking, 'user' do
  fixtures :trackings
  fixtures :users
  fixtures :bills

  it 'should have a user' do
    user = mock_model(User)
    User.should_receive(:find).and_return(user)
    trackings(:bill).user.should == user
  end

  it 'should have have association to trackings' do
    users(:the_bob).trackings.size.should == 1
  end

  it 'should have have association to item being tracked' do
    users(:the_bob).tracked_items.size.should == 1
  end

end

describe Tracking, 'item' do
  fixtures :trackings
  fixtures :bills
  fixtures :users

  it 'should have association to user doing the tracking' do
    bills(:a_bill).users.should_not be_nil
    bills(:a_bill).users.size.should == 1
  end

  it 'should have a bill if tracking bill' do
    bill = mock_model(Bill)
    Bill.should_receive(:find).and_return(bill)

    trackings(:bill).item.should == bill
  end

  it 'should have a committee if tracking committee' do
    committee = mock_model(Committee)
    Committee.should_receive(:find).and_return(committee)

    trackings(:committee).item.should == committee
  end

  it 'should have a portfolio if tracking portfolio' do
    portfolio = mock_model(Portfolio)
    Portfolio.should_receive(:find).and_return(portfolio)

    trackings(:portfolio).item.should == portfolio
  end

  it 'should find trackings for item' do
    bill = bills(:a_bill)
    trackings = Tracking.all_for_item bill
    trackings.size.should == 1
    trackings.first.should == trackings(:bill)
  end
end
