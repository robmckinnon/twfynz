require File.dirname(__FILE__) + '/../spec_helper'

describe Tracking do
  fixtures :trackings
  fixtures :bills
  fixtures :users

  before do
    begin
      @user = User.find(1000001)
    rescue
      user = User.create
      user.login = 'bob'
      user.salt = 1000
      user.email = 'bob@mcbob.com'
      user.blog_url = 'blog.mcbob.com'
      user.hashed_password = '77a0d943cdbace52716a9ef9fae12e45e2788d39' # test
      user.save
      user.id = 1000001
      user.save
      @user = user
    end
  end

  describe 'from_user_and_item' do
    it 'should retrieve tracking given user and bill' do
      bill = bills(:a_bill)
      bill.class.name.should == 'GovernmentBill'
      Tracking.from_user_and_item(@user, bill).should_not be_nil
    end
  end

  describe 'on creation' do
    def create_new params={}
      Tracking.new({:user_id => @user.id,
        :item_id => bills(:a_bill).id,
        :item_type => 'Bill'}.merge(params))
    end

    describe 'after validation' do
      before do
        @tracking = create_new
        @tracking.valid?
      end
      it 'should have tracking_on defaulted to false' do
        @tracking.tracking_on.should be_false
      end
      it 'should have email_alert defaulted to false' do
        @tracking.email_alert.should be_false
      end
      it 'should have include_in_feed defaulted to false' do
        @tracking.include_in_feed.should be_false
      end
      it 'should have created at set automatically' do
        @tracking.created_at.should_not be_nil
      end
      it 'should have item set from item id and type' do
        @tracking.item.should_not be_nil
      end
      it 'should have user set from user id' do
        # @tracking.user.should_not be_nil
      end
    end

    describe 'without user id' do
      it 'should be invalid' do
        tracking = create_new :user_id => nil
        # tracking.save.should be_false
        # tracking.errors.invalid?('user').should be_true
      end
    end

    describe 'without item id' do
      it 'should be invalid' do
        tracking = create_new :item_id => nil
        # tracking.save.should be_false
        # tracking.errors.invalid?('item').should be_true
      end
    end

    it 'should set item id and type from item' do
      tracking = Tracking.new :user_id => @user.id
      tracking.item = bills(:a_bill)
      # tracking.save.should be_true
      tracking.item_id.should == bills(:a_bill).id
      tracking.item_type.should == 'Bill'
      tracking.destroy
    end
  end

  describe 'user' do
    it 'should have a user' do
      user = mock_model(User)
      User.should_receive(:find).and_return(user)
      trackings(:bill).user.should == user
    end

    it 'should have have association to trackings' do
      # @user.trackings.size.should == 1
    end

    it 'should have have association to item being tracked' do
      # @user.tracked_items.size.should == 1
    end
  end

  describe 'item' do
    it 'should have association to user doing the tracking' do
      bills(:a_bill).users.should_not be_nil
      # bills(:a_bill).users.size.should == 1
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
end
