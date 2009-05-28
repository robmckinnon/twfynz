require File.dirname(__FILE__) + '/../spec_helper'

def bill_params
  {:bill_name => 'Major Events Management Bill',
        :parliament_url => '2/5/c/25c94892184b4eb3b38f3d4c465e200d.htm',
        :parliament_id => '2/5/c/25c94892184b4eb3b38f3d4c465e200d.htm',
        :introduction => '2006-12-12',
        :mp_name => 'Rod Donald'}
end

def unvalidated_new_bill params=nil
  new_bill params, false
end

def new_bill params=nil, validate=true
  Mp.should_receive(:from_name).any_number_of_times.and_return(mock_model(Mp))
  bill = GovernmentBill.new(params ? bill_params.merge(params) : bill_params)
  bill.should(be_valid) if validate
  bill
end

def bill_invalid_without param
  params = bill_params; params.delete(param)
  Mp.should_receive(:from_name).and_return(mock_model(Mp))
  bill = GovernmentBill.new(params)
  bill.should_not be_valid
end

describe Bill do

  it 'should respond to find_by_bill_name' do
    Bill.find_by_bill_name('').should be_nil
  end

  describe 'finding by plain bill name and year' do
    before do
      @bill = new_bill bill_params
      @split_bill = unvalidated_new_bill bill_params.merge(:introduction => nil)
    end

    describe 'when plain name does not match' do
      describe 'and there no former name that matches' do
        it 'should not return any bills' do
          Bill.should_receive(:find_all_by_plain_bill_name).and_return []
          bills = Bill.find_all_by_plain_bill_name_and_year(bill_params[:bill_name], 2006)
          bills.should be_empty
        end
      end

      describe 'and there is a plain former name that matches' do
        it 'should return bill' do
          Bill.should_receive(:find_all_by_plain_bill_name).and_return []
          Bill.should_receive(:find_all_by_plain_former_name).and_return [@bill]
          bills = Bill.find_all_by_plain_bill_name_and_year(bill_params[:bill_name], 2006)
          bills.should == [@bill]
        end

        describe 'that has introduction within two years' do
          it 'should return bill' do
            Bill.should_receive(:find_all_by_plain_bill_name).and_return []
            Bill.should_receive(:find_all_by_plain_former_name).and_return [@bill]
            bills = Bill.find_all_by_plain_bill_name_and_year(bill_params[:bill_name], 2008)
            bills.should == [@bill]
          end
        end
      end
    end

    describe 'when plain name matches' do
      describe 'and introduction year matches' do
        it 'should return bill' do
          other_bill = new_bill bill_params.merge(:introduction => '2005-12-12')
          Bill.should_receive(:find_all_by_plain_bill_name).and_return [@bill, other_bill]
          bills = Bill.find_all_by_plain_bill_name_and_year(bill_params[:bill_name], 2006)
          bills.should == [@bill]
        end
      end

      describe 'and bill does not have an introduction date' do
        it 'should not return any bills' do
          @bill = unvalidated_new_bill bill_params.merge(:introduction => nil)
          Bill.should_receive(:find_all_by_plain_bill_name).and_return [@bill]
          bills = Bill.find_all_by_plain_bill_name_and_year(bill_params[:bill_name], 2006)
          bills.should be_empty
        end
      end

      describe 'and former_part_of bill has matching introduction' do
        it 'should return bill' do
          @split_bill.should_receive(:formerly_part_of).and_return @bill
          Bill.should_receive(:find_all_by_plain_bill_name).and_return [@split_bill]
          bills = Bill.find_all_by_plain_bill_name_and_year(bill_params[:bill_name], 2006)
          bills.should == [@split_bill]
        end
      end

      describe 'and former_part_of bill has introduction within one year' do
        it 'should return bill' do
          @split_bill.should_receive(:formerly_part_of).twice.and_return @bill
          Bill.should_receive(:find_all_by_plain_bill_name).and_return [@split_bill]
          bills = Bill.find_all_by_plain_bill_name_and_year(bill_params[:bill_name], 2007)
          bills.should == [@split_bill]
        end
      end
    end
  end

  describe 'with introduction date' do
    it 'should have date of earliest recorded activity equal to introduction date' do
      bill = new_bill
      date = bill_params[:introduction]
      bill.earliest_date.to_s.should eql(date)
    end
  end

  describe 'with first reading negatived' do
    before do
      @bill = new_bill(:first_reading_negatived => true)
    end
    it 'should have first reading negatived' do
      @bill.first_reading_negatived.should be_true
    end
    it 'should not be current' do
      @bill.current?.should be_false
    end
  end

  describe 'unique url identifier' do
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

  describe "on creation" do
    describe 'when has valid attributes' do
      it 'should be valid' do
        bill = new_bill
      end
    end

    describe 'when without a bill name' do
      it 'should be invalid' do
        bill_invalid_without :bill_name
      end
    end

    describe 'when without a parliament_url' do
      it 'should be invalid' do
        bill_invalid_without :parliament_url
      end
    end

    describe 'when without date of earliest recorded activity' do
      it 'should be invalid' do
        bill_invalid_without :introduction
      end
    end

    describe "when it doesn't have an earliest date and bill is formerly part of other bill" do
      it "should have earliest date set to formerly part of bill's earliest date" do
        former_bill = mock_model(Bill)
        former_bill.stub!(:id).and_return(1)
        former_bill.should_receive(:earliest_date).and_return Date.new(2007,9,11)

        Bill.should_receive(:find_by_bill_name).with('Aviation Security Legislation Bill').and_return former_bill
        Bill.should_receive(:find).with(1).and_return former_bill
        Mp.should_receive(:from_name).and_return(mock_model(Mp))

        Bill.should_receive(:find_by_url).with('major_events_management').and_return nil
        bill = Bill.new(bill_params.merge(:introduction => nil, :bill_change => '(Formerly part of Aviation Security Legislation Bill)'))
        bill.should be_valid
        bill.earliest_date.should == Date.new(2007,9,11)
      end
    end

    describe 'when introduced by MP is not a known MP' do
      it 'should be invalid' do
        bill = Bill.new(bill_params.merge(:mp_name => 'Red Herring'))
        lambda { bill.valid? }.should raise_error(Exception, /Validation failed/)
      end
    end

    describe 'when created' do
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

      def check_plain_name name, plain_name
        bill = new_bill :bill_name => name
        bill.plain_bill_name.should == plain_name
      end

      def check_plain_former_name name, plain_name
        bill = new_bill :former_name => name
        bill.plain_former_name.should == plain_name
      end

      it 'should have plain bill name set to be bill name without parentheses, without dashes, without single quotes' do
        check_plain_name 'Social Security (Long-term Residential Care) Amendment Bill', 'Social Security Longterm Residential Care Amendment Bill'
        check_plain_name 'Companies (Minority Buy-out Rights) Amendment Bill', 'Companies Minority Buyout Rights Amendment Bill'
        check_plain_name "Copyright (New Technologies and Performers' Rights) Amendment Bill", 'Copyright New Technologies and Performers Rights Amendment Bill'
        check_plain_name "Arms Amendment Bill (No 3)", 'Arms Amendment Bill No 3'
        check_plain_name "Appropriation (2008/09 Estimates) Bill", 'Appropriation 200809 Estimates Bill'
      end

      it 'should have plain former bill name set to be bill name without parentheses, without dashes, without single quotes' do
        check_plain_former_name 'Social Security (Long-term Residential Care) Amendment Bill', 'Social Security Longterm Residential Care Amendment Bill'
        check_plain_former_name 'Companies (Minority Buy-out Rights) Amendment Bill', 'Companies Minority Buyout Rights Amendment Bill'
        check_plain_former_name "Copyright (New Technologies and Performers' Rights) Amendment Bill", 'Copyright New Technologies and Performers Rights Amendment Bill'
        check_plain_former_name "Arms Amendment Bill (No 3)", 'Arms Amendment Bill No 3'
        check_plain_former_name "Appropriation (2008/09 Estimates) Bill", 'Appropriation 200809 Estimates Bill'
      end
    end

    describe "when referred_to is present" do
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

    describe "when bill_change specifies former name" do
      it 'should populate former name' do
        bill = new_bill :bill_change => '(Formerly Commissioner for Children Bill)'
        bill.former_name.should eql('Commissioner for Children Bill')
      end
    end

    describe "when bill_change specifies formerly part of" do
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
  end

  describe 'when referred to committee' do

    it 'should have a referred to committee' do
      bill = Bill.new(bill_params.merge(:referred_to_committee_id=>1))
      committee = mock_model Committee
      Committee.should_receive(:find).with(1, anything).and_return committee

      bill.referred_to_committee.should eql(committee)
    end
  end

  describe 'when formerly part of another bill' do
    assert_model_belongs_to :formerly_part_of

    it 'should have reference to former part of bill' do
      id = 123
      former_bill = Bill.new(bill_params.merge(:bill_name => 'Statutes Amendment Bill (No 2)'))
      Bill.should_receive(:find).with(id, anything).and_return former_bill

      Bill.should_receive(:find_by_url).with('major_events_management').and_return nil
      bill = new_bill :formerly_part_of_id => id
      bill.formerly_part_of.should == former_bill
    end
  end

  describe 'when divided into other bills' do
    assert_model_has_many :divided_into_bills

    it 'should have reference to divided into bills' do
      Mp.should_receive(:from_name).twice.and_return(mock_model(Mp))

      former_bill = GovernmentBill.new bill_params.merge(:bill_name => 'Statutes Amendment Bill (No 2)')
      former_bill.save!
      bill = GovernmentBill.new bill_params.merge(:formerly_part_of_id => former_bill.id)
      bill.save!

      former_bill.divided_into_bills.first.should eql(bill)

      Bill.delete_all
    end
  end

  describe "on update" do
    it 'should raise error if committee not found when referred_to is present' do
      bill = GovernmentBill.new(bill_params)
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

  describe 'when asked for bill events' do
    assert_model_has_many :bill_events
  end

  describe 'when asked for party in charge' do
    before do
      @bill = Bill.new
    end
    describe 'and there is a member in charge' do
      describe 'that belongs to a party' do
        it 'should return party of member' do
          party = mock('party', :short=>name)
          @bill.should_receive(:member_in_charge).twice.and_return mock('member', :party=>party)
          @bill.party_in_charge.should == party
        end
      end
      describe 'that does not belong to a party' do
        it 'should return nil' do
          @bill.should_receive(:member_in_charge).twice.and_return mock('member', :party=>nil)
          @bill.party_in_charge.should be_nil
        end
      end
    end
    describe 'and there is no member in charge' do
      it 'should return nil' do
        @bill.should_receive(:member_in_charge).and_return nil
        @bill.party_in_charge.should be_nil
      end
    end
  end

  describe 'when asked for last event' do
    before do
      @bill = Bill.new
      @date = mock('date')
      @name = 'name'
      @event = [@date, @name]
    end

    describe 'and bill has events' do
      it 'should return last event' do
        @bill.should_receive(:events_by_date).and_return [@event]
        @bill.last_event.should == @event
      end
    end
    describe 'and bill has no events' do
      it 'should return nil' do
        @bill.should_receive(:events_by_date).and_return []
        @bill.last_event.should be_nil
      end
    end

    describe 'date' do
      describe 'and bill has events' do
        it 'should return date of last event' do
          @bill.should_receive(:last_event).twice.and_return @event
          @bill.last_event_date.should == @date
        end
      end
      describe 'and bill has no events' do
        it 'should return nil' do
          @bill.should_receive(:last_event).and_return nil
          @bill.last_event_date.should be_nil
        end
      end
    end

    describe 'name' do
      describe 'and bill has events' do
        it 'should return name of last event' do
          @bill.should_receive(:last_event).twice.and_return @event
          @bill.last_event_name.should == @name
        end
      end
      describe 'and bill has no events' do
        it 'should return nil' do
          @bill.should_receive(:last_event).and_return nil
          @bill.last_event_name.should be_nil
        end
      end
    end
  end

  describe 'when finding bills from text' do
    def check_bills billname1, and_the, billname2
      date = mock('date')
      bill1 = mock('bill1')
      bill2 = mock('bill2')
      Bill.should_receive(:from_name_and_date).with(billname1, date).and_return bill1
      Bill.should_receive(:from_name_and_date).with(billname2, date).and_return bill2
      Bill.bills_from_text_and_date("#{billname1}#{and_the} #{billname2}", date).should == [bill1, bill2]
    end

    it 'should match on two bills separated by ", and the"' do
      check_bills 'Biosecurity Amendment Bill', ', and the', 'Hazardous Substances and New Organisms Amendment Bill (No 2)'
    end

    it 'should match on two bills separated by " and the"' do
      check_bills 'Biosecurity Amendment Bill', ' and the', 'Hazardous Substances and New Organisms Amendment Bill (No 2)'
    end

    it 'should match on bill ending with (No 4) joined to another bill with "and the" text' do
      check_bills 'Biosecurity Amendment Bill (No 4)', ' and the', 'Hazardous Substances and New Organisms Amendment Bill (No 2)'
    end

    it 'should ignore bills joined by "/" character' do
      check_bills = 'Judicature Amendment Bill (No 2)', ',', 'Te Ture Whenua Maori Amendment Bill (No 2) / Maori Land Amendment Bill (No 2)'
    end
  end

  describe 'bill with debates' do
    before do
      @bill = Bill.new
      @debate = mock('debate')
      @debates = [@debate]
      @bill.stub!(:debates).and_return @debates
    end

    describe 'when asked if it has debates' do
      it 'should return true' do
        @bill.has_debates?.should be_true
      end
    end
    describe 'when asked for debates in groups by name' do
      it 'should return debates in groups by name' do
        debates_in_groups_by_name = mock('debates_in_groups_by_name')
        Debate.should_receive(:debates_in_groups_by_name).with(@debates).and_return debates_in_groups_by_name
        @bill.debates_in_groups_by_name.should == debates_in_groups_by_name
      end
    end
  end

  describe 'bill without debates' do
    before do
      @bill = Bill.new
      @bill.stub!(:debates).and_return []
    end
    describe 'when asked if it has debates' do
      it 'should return false' do
        @bill.has_debates?.should be_false
      end
    end
    describe 'when asked for debates in groups by name' do
      it 'should return an empty array' do
        @bill.debates_in_groups_by_name.should == []
      end
    end
  end
end
