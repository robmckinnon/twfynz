require File.dirname(__FILE__) + '/../spec_helper'

describe SpeakerName, "when creating anchor" do

  it 'should handle Acting Chairperson' do
    anchor_correct 'Acting Chairperson of the Commerce Committee', 'GORDON COPELAND', 'acting_chairperson'
  end

  it 'should handle Acting Minister' do
    anchor_correct 'Acting Minister for ACC', 'Hon RUTH DYSON', 'acting_minister'
    anchor_correct 'Acting Minister in charge of Treaty of Waitangi Negotiations', 'Hon MITA RIRINUI', 'acting_minister'
    anchor_correct 'Acting Minister of Commerce', 'Hon JUDITH TIZARD', 'acting_minister'
    anchor_correct 'Acting Minister responsible for Climate Change Issues', 'Hon Dr MICHAEL CULLEN', 'acting_minister'
  end

  it 'should handle Associate Minister' do
    anchor_correct 'Associate Minister for Arts, Culture and Heritage', 'Hon JUDITH TIZARD', 'associate_minister'
    anchor_correct 'Associate Minister in charge of Treaty of Waitangi Negotiations', 'Hon MITA RIRINUI', 'associate_minister'
    anchor_correct 'Associate Minister of Commerce', 'Hon JUDITH TIZARD', 'associate_minister'
  end

  it 'should handle Acting Prime Minister' do
    anchor_correct 'Acting Prime Minister', 'Hon RUTH DYSON', 'acting_prime_minister'
  end

  it 'should handle Deputy Prime Minister' do
    anchor_correct 'Deputy Prime Minister', 'Hon Dr MICHAEL CULLEN', 'deputy_prime_minister'
  end

  it 'should handle Prime Minister' do
    anchor_correct 'Prime Minister', 'Rt Hon HELEN CLARK', 'prime_minister'
  end

  it 'should handle Attorney-General' do
    anchor_correct 'Attorney-General', 'Hon DAVID PARKER', 'attorney-general'
  end

  it 'should handle party-electorate' do
    anchor_correct 'ACT—Epsom', 'RODNEY HIDE', 'act'
  end

  it 'should handle The ASSISTANT SPEAKER' do
    anchor_correct 'Ann Hartley', 'The ASSISTANT SPEAKER', 'assistant_speaker'
  end

  it 'should handle The CHAIRPERSON' do
    anchor_correct 'Ann Hartley', 'The CHAIRPERSON', 'chairperson'
  end

  it 'should handle Chairperson' do
    anchor_correct 'Chairperson of the Commerce Committee', 'GERRY BROWNLEE', 'chairperson'
  end

  it 'should handle Co-Leader—party' do
    anchor_correct 'Co-Leader—Green', 'JEANETTE FITZSIMONS', 'green'
    anchor_correct 'Co-Leader—Māori Party', 'Dr PITA SHARPLES', 'maori_party'
  end

  it 'should handle Deputy Chairperson' do
    anchor_correct 'Deputy Chairperson of the Finance and Expenditure Committee', 'Dr the Hon LOCKWOOD SMITH', 'deputy_chairperson'
  end

  it 'should handle Deputy Leader of the House' do
    anchor_correct 'Deputy Leader of the House', 'Hon DARREN HUGHES', 'deputy_leader_of_the_house'
  end

  it 'should handle Leader of the House' do
    anchor_correct 'Leader of the House', 'Hon Dr MICHAEL CULLEN', 'leader_of_the_house'
  end

  it 'should handle Deputy Leader—party' do
    anchor_correct 'Deputy Leader—ACT', 'HEATHER ROY', 'act'
  end

  it 'should handle Leader of the Opposition' do
    anchor_correct 'Leader of the Opposition', 'Dr DON BRASH', 'national'
  end

  it 'should handle Leader—party' do
    anchor_correct 'Leader—NZ First', 'Rt Hon WINSTON PETERS', 'nz_first'
  end

  it 'should handle party' do
    anchor_correct 'Green', 'KEITH LOCKE', 'green'
  end

  it 'should handle party-electorate' do
    anchor_correct 'Independent—Mangere', 'TAITO PHILLIP FIELD', 'independent'
    anchor_correct 'Māori Party—Te Tai Hauauru', 'TARIANA TURIA', 'maori_party'
  end

  it 'should handle The TEMPORARY SPEAKER' do
    anchor_correct 'Jill Pettis', 'The TEMPORARY SPEAKER', 'temporary_speaker'
  end

  it 'should handle Junior Whip—party' do
    anchor_correct 'Junior Whip—Labour', 'DARREN HUGHES', 'labour'
  end

  it 'should handle Musterer—party' do
    anchor_correct 'Musterer—Green', 'METIRIA TUREI', 'green'
  end

  it 'should handle Senior Whip—party' do
    anchor_correct 'Senior Whip—Labour', 'TIM BARNETT', 'labour'
  end

  it 'should handle Whip—party' do
    anchor_correct 'Whip—ACT', 'HEATHER ROY', 'act'
  end

  it 'should handle Member in charge' do
    anchor_correct 'Member in charge of Westpac New Zealand Bill', 'Hon MARIAN HOBBS', 'member_in_charge'
  end

  it 'should handle Minister in charge' do
    anchor_correct 'Minister in charge of the NZ Security Intelligence Service', 'Rt Hon HELEN CLARK', 'minister_in_charge'
  end

  it 'should handle Minister' do
    anchor_correct 'Minister for ACC', 'Hon MARYAN STREET', 'minister'
    anchor_correct 'Minister of Revenue', 'Hon PETER DUNNE', 'minister'
    anchor_correct 'Minister responsible for Climate Change Issues', 'Hon DAVID PARKER', 'minister'
  end

  def anchor_correct remaining, name, expected
    speaker_name = SpeakerName.new ''
    speaker_name.stub!(:name).and_return name
    speaker_name.stub!(:remaining).and_return remaining
    speaker_name.anchor.should == expected
  end

end
