require File.dirname(__FILE__) + '/../spec_helper'

describe Organisation, 'when finding organisation from text' do
  assert_model_has_many :donations

  describe 'when finding organisation from text' do

    def check_found text, name, options={:found => :on_first_try}
      organisation = mock(Organisation)
      Organisation.should_receive(:find_by_name).with(text).and_return(nil) if (options[:found] == :on_second_try || options[:found] == :on_third_try)
      Organisation.should_receive(:find_by_name).with(options[:second_try]) if options[:found] == :on_third_try
      Organisation.should_receive(:find_by_name).with(name).and_return organisation
      Organisation.from_name(text).should == organisation
    end

    def check_found_on_second_try text, name
      check_found text, name, :found => :on_second_try
    end

    def check_found_on_third_try text, second_try, name
      check_found text, name, :found => :on_third_try, :second_try => second_try
    end

    it 'should find organisation when text matches an organisation name' do
      check_found 'Genesis Energy', 'Genesis Energy'
    end

    it 'should find organisation when text ends with Supp1' do
      check_found 'Genesis Energy Supp1', 'Genesis Energy'
    end

    it 'should find organisation when text ends with 2' do
      check_found 'Genesis Energy 2', 'Genesis Energy'
    end

    it 'should find organisation when text ends with 3' do
      check_found 'Genesis Energy 3', 'Genesis Energy'
    end

    it 'should find organisation when text ends with supp1' do
      check_found 'Genesis Energy supp1', 'Genesis Energy'
    end

    it 'should find organisation when text ends with supp 1' do
      check_found 'Genesis Energy supp 1', 'Genesis Energy'
    end

    it 'should find organisation when text ends with Supp 1' do
      check_found 'Genesis Energy Supp 1', 'Genesis Energy'
    end

    it 'should find organisation when text ends with Appendix' do
      check_found 'Genesis Energy Appendix', 'Genesis Energy'
    end

    it 'should find organisation when text ends with Part 3' do
      check_found 'Real Estate Institute of New Zealand Part 3', 'Real Estate Institute of New Zealand'
    end

    it 'should find organisation when text ends with Appendix 1' do
      check_found 'Real Estate Institute of New Zealand Appendix 1', 'Real Estate Institute of New Zealand'
    end

    it 'should find organisation when text provided ends with Limited' do
      check_found_on_second_try 'Genesis Energy Limited', 'Genesis Energy'
    end

    it 'should find organisation when text provided ends with Limted' do
      check_found_on_second_try 'Genesis Energy Limted', 'Genesis Energy'
    end

    it 'should find organisation when text starts with "The" but name does not' do
      check_found_on_second_try 'The Royal Forest and Bird Protection Society', 'Royal Forest and Bird Protection Society'
    end

    it 'should find organisation when text starts with "The" but name does not' do
      check_found_on_third_try 'The Royal Forest and Bird Protection Society', 'Royal Forest and Bird Protection Society', 'Royal Forest and Bird Protection Society of New Zealand'
    end

    it 'should find organisation when text provided ends with Inc' do
      check_found_on_second_try 'Genesis Energy Inc', 'Genesis Energy'
    end

    it 'should find organisation when name in database ends with Limited' do
      check_found_on_second_try 'Genesis Energy', 'Genesis Energy Limited'
    end

    it 'should find organisation when text has New Zealand and name has NZ' do
      check_found_on_second_try 'Wood Processors Association of New Zealand', 'Wood Processors Association of NZ'
    end

    it 'should find organisation when text has NZ and name has New Zealand' do
      check_found_on_second_try 'Wood Processors Association of NZ', 'Wood Processors Association of New Zealand'
    end

    it 'should find organisation when text has Incorporated and name has Inc' do
      check_found_on_second_try 'Wood Council of New Zealand Incorporated', 'Wood Council of New Zealand Inc'
    end

    it 'should find organisation when name provided ends with New Zealand Limited but text does not' do
      check_found_on_third_try 'Transpower', 'Transpower Limited',  'Transpower New Zealand Limited'
    end

    it 'should find organisation when text provided ends with Limted and actual name ends in Limited' do
      check_found 'New Zealand Steel Limted', 'New Zealand Steel Limited'
    end

  end

  describe 'on creation' do

    before(:each) do ||
      Organisation.delete_all
    end

    after(:each) do ||
      Organisation.delete_all
    end

    def new_organisation url='nzoss.org.nz', name='The New Zealand Open Source Society'
      Organisation.new :url => url, :name => name
    end

    it 'should be invalid without name' do
      organisation = Organisation.new :url => 'http://nzoss.org.nz/'
      organisation.valid?.should be_false
    end

    it 'should be valid without url' do
      organisation = Organisation.new :name => 'The New Zealand Open Source Society'
      organisation.valid?.should be_true
    end

    it 'should have url protocol removed before being stored' do
      organisation = new_organisation 'http://nzoss.org.nz'
      organisation.valid?.should be_true
      organisation.url.should == 'nzoss.org.nz'
    end

    it 'should have url trailing slash removed before being stored' do
      organisation = new_organisation 'nzoss.org.nz/'
      organisation.valid?.should be_true
      organisation.url.should == 'nzoss.org.nz'
    end

    it 'should be invalid if missing root domain' do
      organisation = new_organisation 'nzoss'
      organisation.valid?.should be_false
    end

    it 'should be invalid if root domain too small' do
      organisation = new_organisation 'nzoss.org.n'
      organisation.valid?.should be_false
    end

    it 'should be invalid if missing root domain after dot' do
      organisation = new_organisation 'nzoss.org.'
      organisation.valid?.should be_false
    end

    it 'should be invalid if organisation exists with the same name' do
      organisation = new_organisation
      organisation.save!
      organisation = new_organisation 'http://auoss.org.au/', 'The New Zealand Open Source Society'
      organisation.valid?.should be_false
    end

    it 'should be invalid if organisation exists with the same url' do
      organisation = new_organisation
      organisation.save!
      organisation = new_organisation 'http://nzoss.org.nz/', 'The Australian Open Source Society'
      organisation.valid?.should be_false
    end

    it 'should be valid when name and url specified correctly' do
      organisation = new_organisation
      organisation.valid?.should be_true
      organisation.name.should == 'The New Zealand Open Source Society'
      organisation.url.should == 'nzoss.org.nz'
    end

    it 'should create slug "nz_open_source_society" if name is "The New Zealand Open Source Society"' do
      organisation = new_organisation
      organisation.valid?.should be_true
      organisation.slug.should == 'nz_open_source_society'
    end

    it 'should set name to "Reserve Bank of New Zealand" if name is "Reserve Bank of New Zealand Supp2"' do
      organisation = new_organisation 'http://www.rbnz.govt.nz/','Reserve Bank of New Zealand Supp2'
      organisation.valid?.should be_true
      organisation.name.should == 'Reserve Bank of New Zealand'
    end

    it 'should set name to "Ngāi Tahu" if name is "Ngāi Tahu"' do
      organisation = new_organisation 'http://www.ngaitahu.iwi.nz/','Ngāi Tahu'
      organisation.valid?.should be_true
      organisation.name.should == 'Ngāi Tahu'
    end

    it 'should create slug "ngai_tahu" if name is "Ngāi Tahu"' do
      organisation = new_organisation 'http://www.ngaitahu.iwi.nz/', 'Ngāi Tahu'
      organisation.valid?.should be_true
      organisation.slug.should == 'ngai_tahu'
    end

    it %q|should create slug "albany_students_association" if name is "Albany Students' Association"| do
      organisation = new_organisation 'http://www.ngaitahu.iwi.nz/', "Albany Students' Association"
      organisation.valid?.should be_true
      organisation.slug.should == 'albany_students_association'
    end

    it 'should create slug "ngai_tahu_2" if name is "Ngai Tahu" and slug "ngai_tahu" already exists' do
      organisation = new_organisation 'http://www.ngaitahu.iwi.nz/', 'Ngāi Tahu'
      organisation.save!
      organisation.slug.should == 'ngai_tahu'
      Organisation.find_by_slug('ngai_tahu').should_not be_nil

      organisation = new_organisation 'http://the_ngai_tahu.iwi.nz/', 'The Ngai Tahu'
      organisation.valid?.should be_true
      organisation.slug.should == 'ngai_tahu_2'
    end
  end


  describe 'find mentions of organisation' do
    fixtures :contributions, :organisations, :debates, :portfolios, :bills

    after(:all) do
      Debate.find(:all).each {|d| d.destroy}
    end

    it 'should return correctly when there is one matching contribution' do
      internetnz = organisations(:internetnz)

      mention = contributions(:communications_question)
      Contribution.should_receive(:search_name).twice.with('InternetNZ').and_return([mention])
      Contribution.should_receive(:search_name).twice.with('Internet Society of New Zealand').and_return([])

      internetnz.find_mentions.should == [[[mention]]]
      internetnz.live_count_of_debates_mentioned_in.should == 1
    end

    it 'should return correctly when there is one matching contribution' do
      internetnz = organisations(:internetnz)

      mention = contributions(:communications_question)
      Contribution.should_receive(:search_name).with('InternetNZ').and_return([mention])
      Contribution.should_receive(:search_name).with('Internet Society of New Zealand').and_return([])

      internetnz.find_mentions.should == [[[mention]]]
    end

    it 'should return correctly when there are two matching contributions from one bill debate' do
      internetnz = organisations(:internetnz)

      mention1 = contributions(:bill_continue_speech)
      mention2 = contributions(:bill_speech)
      mention1.stub!(:id).and_return(1)
      mention2.stub!(:id).and_return(2)
      Contribution.should_receive(:search_name).twice.with('InternetNZ').and_return([mention1])
      Contribution.should_receive(:search_name).twice.with('Internet Society of New Zealand').and_return([mention2])

      internetnz.find_mentions.should == [[[mention1, mention2]]]

      mention1.stub!(:id).and_return(2)
      mention2.stub!(:id).and_return(1)

      internetnz.find_mentions.should == [[[mention2, mention1]]]
    end

    it 'should return correctly when there are matches from two different readings on the same bill' do
      internetnz = organisations(:internetnz)

      first_reading = mock_model(BillDebate)
      first_reading.stub!(:about).and_return(bills(:a_bill))
      first_reading.stub!(:date).and_return(debates(:bill_reading).date + 1)

      mention1 = contributions(:bill_continue_speech)
      mention2 = contributions(:bill_speech)

      mention1.stub!(:debate).and_return(first_reading)

      Contribution.should_receive(:search_name).any_number_of_times.with('InternetNZ').and_return([mention1])
      Contribution.should_receive(:search_name).any_number_of_times.with('Internet Society of New Zealand').and_return([mention2])

      internetnz.find_mentions.should == [[[mention1],[mention2]]]

      first_reading.stub!(:date).and_return(debates(:bill_reading).date - 1)

      internetnz.find_mentions.should == [[[mention2],[mention1]]]
      internetnz.live_count_of_debates_mentioned_in.should == 2
    end

    it 'should return correctly when there are matches from several different debates' do
      internetnz = organisations(:internetnz)
      mention1   = contributions(:communications_question)
      mention2   = contributions(:bill_continue_speech)
      mention3   = contributions(:bill_speech)
      mention4   = contributions(:speech)

      Contribution.should_receive(:search_name).any_number_of_times.with('InternetNZ').and_return([mention1,mention3])
      Contribution.should_receive(:search_name).any_number_of_times.with('Internet Society of New Zealand').and_return([mention2,mention4])

      date = Date.new(2006,11,11)
      mention1.debate.date = date + 2
      mention2.debate.date = date + 1
      mention3.debate.date = date + 1
      mention4.debate.date = date

      mentions = internetnz.find_mentions
      mentions.should == [[[mention1]],[[mention2,mention3]],[[mention4]]]

      mention1.debate.date = date
      mention2.debate.date = date + 1
      mention3.debate.date = date + 1
      mention4.debate.date = date + 2

      internetnz.find_mentions.should == [[[mention4]],[[mention2,mention3]],[[mention1]]]
      internetnz.live_count_of_debates_mentioned_in.should == 3
    end

  end
end
