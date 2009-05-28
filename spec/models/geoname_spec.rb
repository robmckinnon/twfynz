require File.dirname(__FILE__) + '/../spec_helper'

describe Geoname, 'when matching geonames in text' do
  fixtures :geonames

  def should_be_no_match text
    Geoname.matches(text).should == []
  end

  it 'should return match for geoname occurance inside <li> tags' do
    Geoname.matches('<li>Liverpool</li>').should == [[4, geonames(:liverpool)]]
  end

  it 'should return match for geoname occurance inside <td> tags' do
    Geoname.matches('<td>Liverpool</td>').should == [[4, geonames(:liverpool)]]
  end

  it 'should return first word in matching name correctly' do
    geonames(:ord).first_word_in_name.should == 'Ord'
  end

  it 'should not match parts of a word that match a place name' do
    should_be_no_match 'Order Paper'
  end

  it 'should not match when placename is in pattern "Lord Ernie of Liverpool"' do
    should_be_no_match 'Lord Ernie of Liverpool'
  end

  it 'should not match persons surname in pattern "Mrs. Estelle Liverpool"' do
    should_be_no_match 'Mrs. Estelle Liverpool'
  end

  it 'should not match persons surname in pattern "Mrs. Liverpool"' do
    should_be_no_match 'Mrs. Liverpool'
  end

  it 'should not match persons surname in pattern "Mr Ernie Liverpool"' do
    should_be_no_match 'Mr Ernie Liverpool'
  end

  it 'should not match persons surname in pattern "Mr Liverpool"' do
    should_be_no_match 'Mr Liverpool'
  end

  it 'should not match persons surname in pattern "Mr. Liverpool."' do
    should_be_no_match 'matter again. Mr. Liverpool.'
  end

  it 'should return a match for a placename which occurs in the geonames list once, e.g. Liverpool' do
    Geoname.matches('a Liverpool pharmacist').should == [[2, geonames(:liverpool)]]
  end

  it 'should return both matches for two different placenames in a piece of text' do
    Geoname.matches('from Ord or Liverpool mylord?').should == [[5, geonames(:ord)],[12, geonames(:liverpool)]]
  end

  it 'should return match for placenames in parentheses' do
    Geoname.matches('town (Liverpool)').should == [[6, geonames(:liverpool)]]
  end

  it 'should return a match for a placename followed by a question mark' do
    Geoname.matches('from Liverpool?').should == [[5, geonames(:liverpool)]]
  end

  it 'should return match for placename followed by punctuation' do
    Geoname.matches('town Liverpool,').should == [[5, geonames(:liverpool)]]
    Geoname.matches('town Liverpool;').should == [[5, geonames(:liverpool)]]
    Geoname.matches('town Liverpool:').should == [[5, geonames(:liverpool)]]
    Geoname.matches('town Liverpool' ).should == [[5, geonames(:liverpool)]]
    Geoname.matches('town Liverpool.').should == [[5, geonames(:liverpool)]]
    Geoname.matches('town Liverpool!').should == [[5, geonames(:liverpool)]]
    Geoname.matches('town Liverpool?').should == [[5, geonames(:liverpool)]]
  end

  it 'should return two matches for two occurances of the same placenames in a piece of text' do
    matches = Geoname.matches('from Ord to Ord mylord?')
    matches.should == [ [5, geonames(:ord)], [12, geonames(:ord)]]
  end

  it 'should return a match for a hyphenated placename correctly' do
    Geoname.matches('that Stoke-on-Trent is meant').should == [[5, geonames(:stoke_on_trent)]]
  end

  it 'should not return a match a placename which occurs in the geonames list multiple times, e.g. Leigh' do
    should_be_no_match 'a Leigh pharmacist'
  end

  it 'should not return placename which occurs inside another placename, e.g. London in "City of London"' do
    Geoname.matches('City of London').should == [[0, geonames(:city_of_london)]]
  end

  it 'should render as a geo microformat correctly' do
    geoname = geonames(:liverpool)
    geoname.microformatted.should == '<span class="geo">Liverpool<span class="space"> </span><span class="latitude">53.4166667</span><span class="space"> </span><span class="longitude">-3.0</span></span>'
  end

end

describe Geoname, ' when formatting two geoname occurances' do
  fixtures :geonames

  before do
    liverpool = geonames(:liverpool)
    ord = geonames(:ord)
    @text = 'from Liverpool to Ord'
    Geoname.should_receive(:matches).with(@text).and_return([[5,liverpool],[18,ord]])
  end

  it 'should replace original place name text with markedup version correctly' do
    formatted = Geoname.format_geonames(@text)
    formatted.should == 'from <span class="geo">Liverpool<span class="space"> </span><span class="latitude">53.4166667</span><span class="space"> </span><span class="longitude">-3.0</span></span> to <span class="geo">Ord<span class="space"> </span><span class="latitude">57.1333333</span><span class="space"> </span><span class="longitude">-5.95</span></span>'
  end
end

describe Geoname, ' when formatting a non-relevant geoname occurance' do
  fixtures :geonames
  it 'should not match persons surname in pattern "Mr. Liverpool"' do
    geoname = geonames(:liverpool)
    text = 'Mr. Liverpool'
    Geoname.should_receive(:matches).with(text).and_return([])
    formatted = Geoname.format_geonames(text)
    formatted.should_not include("<span class=")
  end
end

describe Geoname, ' when formatting a geoname occurance inside <li> tags' do
  fixtures :geonames

  it 'should create span element with class "geo" surrounding place name with latitude and longitude values' do
    formatted = Geoname.format_geonames('<li>Liverpool</li>')
    formatted.should == '<li><span class="geo">Liverpool<span class="space"> </span><span class="latitude">53.4166667</span><span class="space"> </span><span class="longitude">-3.0</span></span></li>'
  end
end

describe Geoname, ' when formatting a single geoname occurance' do
  fixtures :geonames

  before do
    geoname = geonames(:liverpool)
    @text = 'a Liverpool pharmacist'
    Geoname.should_receive(:matches).with(@text).and_return([[2,geoname]])
  end

  it 'should create span element with class "geo" surrounding place name with latitude and longitude values' do
    formatted = Geoname.format_geonames(@text)
    formatted.should include('<span class="geo">Liverpool<span class="space"> </span><span class="latitude">53.4166667</span><span class="space"> </span><span class="longitude">-3.0</span></span>')
  end

  it 'should create span element with class "latitude" surrounding latitude value' do
    formatted = Geoname.format_geonames(@text)
    formatted.should include('<span class="latitude">53.4166667')
  end

  it 'should create span element with class "longitude" surrounding longitude value' do
    formatted = Geoname.format_geonames(@text)
    formatted.should include('<span class="longitude">-3.0') # longitude
  end

  it 'should replace original place name text with markedup version correctly' do
    formatted = Geoname.format_geonames(@text)
    formatted.should == 'a <span class="geo">Liverpool<span class="space"> </span><span class="latitude">53.4166667</span><span class="space"> </span><span class="longitude">-3.0</span></span> pharmacist'
  end

end

