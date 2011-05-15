require File.dirname(__FILE__) + '/../spec_helper'

def mp_from_name_correct date, downcase_name, lookup_name, alt_downcase_name=nil
  mp = mock_model(Mp)
  mp.should_receive(:downcase_name).and_return(downcase_name)
  mp.should_receive(:alt_downcase_name).twice.and_return(alt_downcase_name) if alt_downcase_name
  Mp.should_receive(:find_by_sql).with('select id,first,alt,last from mps').and_return([mp])
  Mp.should_receive(:find).with(mp.id).and_return mp
  Mp.from_name(lookup_name, date).should == mp
end

def mp_params
  { :first => 'Rod',
    :last => 'Donald',
    :elected => '2000',
    :former => 0,
    :id_name => 'rod_donald',
    :img => 'rod.png'}
end

def mp_bill_params
  {:bill_name => 'Major Events Management Bill',
        :parliament_url => '2/5/c/25c94892184b4eb3b38f3d4c465e200d.htm',
        :parliament_id => '2/5/c/25c94892184b4eb3b38f3d4c465e200d.htm',
        :introduction => '2006-12-12',
        :mp_name => 'Rod Donald'}
end

def mp_invalid_without param
  params = mp_params
  params.delete(param)
  mp = Mp.new(params)
  mp.should_not be_valid
end

describe Mp do
  assert_model_has_many :members
  assert_model_has_many :pecuniary_interests
  assert_model_has_many :bills
  assert_model_has_many :contributions
end

describe Mp, 'finding member on date' do
  before do
    @mp = Mp.new
    @date = mock('date')
    @member1 = mock('member')
    @member2 = mock('member')
  end
  it 'should return member on date' do
    @member1.should_receive(:is_active_on).with(@date).and_return false
    @member2.should_receive(:is_active_on).with(@date).and_return true

    @mp.should_receive(:members).and_return [@member1, @member2]
    @mp.member_on_date(@date).should == @member2
  end
  it 'should return nil if no member on date' do
    @member1.should_receive(:is_active_on).with(@date).and_return false
    @member2.should_receive(:is_active_on).with(@date).and_return false

    @mp.should_receive(:members).and_return [@member1, @member2]
    @mp.member_on_date(@date).should be_nil
  end
end

describe Mp, 'finding party on date' do
  it 'should return party from member on date' do
    mp = Mp.new
    party = mock('party')
    date = mock('date')
    member = mock('member', :party => party)
    mp.should_receive(:member_on_date).with(date).and_return member
    mp.party_on_date(date).should == party
  end
  it 'should return nil if no member on date' do
    mp = Mp.new
    date = mock('date')
    mp.should_receive(:member_on_date).with(date).and_return nil
    mp.party_on_date(date).should be_nil
  end
end

describe Mp, 'on validation' do

  it 'should be invalid without last name' do
    mp_invalid_without :last
  end

  it 'should be invalid without first name' do
    mp_invalid_without :first
  end

  it 'should be invalid without first elected year' do
    mp_invalid_without :elected
  end

  it 'should be invalid without id_name' do
    mp_invalid_without :id_name
  end

end

describe Mp, "from_name" do

  describe 'when date is in 48th Parliament' do
    before do
      @date = mock(Date)
      Parliament.stub!(:date_within?).with(48,@date).and_return true
    end

    it 'should return Margaret Wilson for "Madam Speaker"' do
      mp = mock(Mp)
      Mp.should_receive(:find_by_first_and_last).twice.with('Margaret','Wilson').and_return(mp)

      Mp.from_name('Madam Speaker', @date).should == mp
      Mp.from_name('Madam Speaker-elect', @date).should == mp
    end

    it 'should return Helen Clark for "Prime Minister"' do
      mp = mock(Mp)
      Mp.should_receive(:find_by_first_and_last).with('Helen','Clark').and_return(mp)

      Mp.from_name('Prime Minister', @date).should == mp
    end

    it 'should return Michael Cullen for "Deputy Prime Minister"' do
      mp = mock(Mp)
      Mp.should_receive(:find_by_first_and_last).with('Michael','Cullen').and_return(mp)

      Mp.from_name('Deputy Prime Minister', @date).should == mp
    end

    it 'should return Clem Simich for "Mr Deputy Speaker"' do
      mp = mock(Mp)
      Mp.should_receive(:find_by_first_and_last).with('Clem','Simich').and_return(mp)

      Mp.from_name('Mr Deputy Speaker', @date).should == mp
    end

    it 'should return nil for "Hon Member."' do
      Mp.from_name('Hon Member.', @date).should be_nil
    end

    it 'should return nil for "Hon Member"' do
      Mp.from_name('Hon Member', @date).should be_nil
    end

    it 'should return nil for "Hon Members"' do
      Mp.from_name('Hon Member', @date).should be_nil
    end

    it 'should return nil for "The CHAIRPERSON"' do
      Mp.from_name('The CHAIRPERSON', @date).should be_nil
    end

    it 'should return Hone Harawira for "Hone Harawira"' do
      mp_from_name_correct @date, 'hone harawira', 'Hone Harawira'
    end

    it 'should return Lockwood Smith for "Dr the Hon Lockwood Smith"' do
      mp_from_name_correct @date, 'lockwood smith', 'Dr the Hon Lockwood Smith'
    end

    it 'should return Helen Clark for "Rt Hon HELEN CLARK"' do
      mp_from_name_correct @date, 'helen clark', 'Rt Hon HELEN CLARK'
    end

    it 'should return Michael Cullen for "Hon Dr MICHAEL CULLEN"' do
      mp_from_name_correct @date, 'michael cullen', 'Hon Dr MICHAEL CULLEN'
    end

    it 'should return Michael Cullen for "Hon Dr MICHAEL CULLEN (Leader of the House)"' do
      mp_from_name_correct @date, 'michael cullen', 'Hon Dr MICHAEL CULLEN (Leader of the House)'
    end

    it 'should return Parekura Horomia for "Hon Parekura Horomia"' do
      mp_from_name_correct @date, 'parekura horomia', 'Hon Parekura Horomia'
    end

    it 'should return Pita Sharples for "Dr Pita Sharples"' do
      mp_from_name_correct @date, 'pita sharples', 'Dr Pita Sharples'
    end

    it 'should return Ann Hartley for "The ASSISTANT SPEAKER (Ann Hartley)"' do
      mp_from_name_correct @date, 'ann hartley', 'The ASSISTANT SPEAKER (Ann Hartley)'
    end

    it 'should return H V Ross Robertson for "The CHAIRPERSON (H V Ross Robertson)"' do
      mp_from_name_correct @date, 'ross robertson', 'The CHAIRPERSON (H V Ross Robertson)', 'h v ross robertson'
    end

    it 'should return Jill Pettis for "The TEMPORARY SPEAKER (Jill Pettis)"' do
      mp_from_name_correct @date, 'jill pettis', 'The TEMPORARY SPEAKER (Jill Pettis)'
    end

    it 'should return Damien O\'Connor (Minister of Corrections) for "Hon DAMIEN O’CONNOR (Minister of Corrections)"' do
      mp_from_name_correct @date, "damien o'connor", 'Hon DAMIEN O’CONNOR (Minister of Corrections)'
    end

  end

  describe 'when date is in 49th Parliament' do
    before do
      Parliament.stub!(:date_within?).with(48,@date).and_return false
      Parliament.stub!(:date_within?).with(49,@date).and_return true
    end

    it 'should return Lockwood Smith for "Mr Speaker"' do
      mp = mock(Mp)
      Mp.should_receive(:find_by_first_and_last).twice.with('Lockwood','Smith').and_return(mp)

      Mp.from_name('Mr SPEAKER', @date).should == mp
      Mp.from_name('Mr SPEAKER-ELECT', @date).should == mp
    end

    it 'should return John Key for "Prime Minister"' do
      mp = mock(Mp)
      Mp.should_receive(:find_by_first_and_last).with('John','Key').and_return(mp)

      Mp.from_name('Prime Minister', @date).should == mp
    end

    it 'should return Bill English for "Deputy Prime Minister"' do
      mp = mock(Mp)
      Mp.should_receive(:find_by_first_and_last).with('Bill','English').and_return(mp)

      Mp.from_name('Deputy Prime Minister', @date).should == mp
    end

    it 'should return Lindsay Tisch for "Mr Deputy Speaker"' do
      mp = mock(Mp)
      Mp.should_receive(:find_by_first_and_last).with('Lindsay','Tisch').and_return(mp)

      Mp.from_name('Mr Deputy Speaker', @date).should == mp
    end
  end

end

describe Mp, 'if current' do

  it 'should have party' do
    mp = Mp.new(mp_params.merge(:member_of_id=>1))
    party = mock_model Party
    Party.should_receive(:find).with(1, anything).and_return party

    mp.party.should eql(party)
  end

end

describe Mp, 'if member in charge of bills' do

  it 'should have bills' do
    mp = Mp.new mp_params
    mp.save!
    bill = GovernmentBill.create mp_bill_params.merge(:member_in_charge_id => mp.id)
    mp.bills.size.should == 1
    mp.bills.first.id.should == bill.id

    Mp.delete_all
    Bill.delete_all
  end

end
