require File.dirname(__FILE__) + '/../spec_helper'


describe Contribution, 'on validation' do

  it 'should be valid when speaker name is "Hon Member"' do
    contribution = Contribution.new(:speaker=>'Hon Member')
    contribution.should be_valid
  end

  it 'should be valid when speaker name is "Hon Member"' do
    contribution = Contribution.new(:speaker=>'Hon Member.')
    contribution.should be_valid
  end
end

describe Contribution, 'finding first sentence' do

  it 'should find up to first full stop' do
    Contribution.new(:text=>'<p><em>one</em>. two.').first_sentence.should == 'one.'
  end

  it 'should find up to first question mark' do
    Contribution.new(:text=>'<p>one? two?').first_sentence.should == 'one?'
  end

  it 'should find up to first full stop, when there is a question mark later' do
    Contribution.new(:text=>'<p>one. two?').first_sentence.should == 'one.'
  end

  it 'should find up to first question mark, when there is a full stop later' do
    Contribution.new(:text=>'<p>one? two.').first_sentence.should == 'one?'
  end

  it 'should find up to first semi-colon, when there is a full stop later' do
    Contribution.new(:text=>'<p>one; two.').first_sentence.should == 'one;'
  end

  it 'should pick second sentence if first sentence is "I raise a point of order, Madam Speaker."' do
    Contribution.new(:text=>'<p>I raise a point of order, Madam Speaker. two.').first_sentence.should == 'two.'
    Contribution.new(:text=>'<p>I raise a point of order, Mr Speaker. two.').first_sentence.should == 'two.'
  end

  it 'should pick first sentence if first sentence is "I raise a point of order, Madam Speaker." and there is no second sentence' do
    Contribution.new(:text=>'<p>I raise a point of order, Madam Speaker.').first_sentence.should == 'I raise a point of order, Madam Speaker.'
    Contribution.new(:text=>'<p>I raise a point of order, Mr Speaker.').first_sentence.should == 'I raise a point of order, Mr Speaker.'
  end
end
