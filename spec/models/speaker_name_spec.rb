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

  it 'should handle The CHAIRPERSON with name in brackets' do
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

  it 'should handle Mr Speaker' do
    anchor_correct nil, 'Mr SPEAKER', 'mr_speaker'
    anchor_correct nil, 'Mr SPEAKER-ELECT', 'speaker-elect'
  end

  it 'should handle Madame Speaker' do
    anchor_correct nil, 'Madam SPEAKER', 'madam_speaker'
    anchor_correct nil, 'Madam SPEAKER-ELECT', 'speaker-elect'
  end

  it 'should handle Mr DEPUTY SPEAKER' do
    anchor_correct nil, 'Mr DEPUTY SPEAKER', 'deputy_speaker'
  end

  it 'should handle The CHAIRPERSON' do
    anchor_correct nil, 'The CHAIRPERSON', 'chairperson'
  end

  it 'should remember anchor for same name' do
    anchor_correct 'Green', 'KEITH LOCKE', 'green'
    anchor_correct nil, 'KEITH LOCKE', 'green'
  end

  it 'should remember anchor for same name ignoring case' do
    anchor_correct 'Green', 'KEITH LOCKE', 'green'
    anchor_correct nil, 'Keith Locke', 'green'
  end

  it 'should forget anchor after reset_anchors is called' do
    anchor_correct 'Green', 'KEITH LOCKE', 'green'
    SpeakerName.reset_anchors
    anchor_correct nil, 'KEITH LOCKE', nil
  end

  it 'should handle an independent MP' do
    name = 'TAITO PHILLIP FIELD'
    mp = mock(Mp)
    mp.should_receive(:anchor).with(@date).and_return 'field'
    Mp.should_receive(:from_name).with(name, @date).and_return mp
    speaker_name = create_speaker_name name, 'Independent—Mangere'
    speaker_name.anchor(@date).should == 'field'
  end

  it "should lookup anchor from member's party if no remaining text previously given" do
    mp = mock(Mp)
    mp.should_receive(:anchor).with(@date).and_return 'green'
    name = 'KEITH LOCKE'
    Mp.should_receive(:from_name).with(name, @date).and_return mp
    speaker_name = create_speaker_name name, nil
    speaker_name.anchor(@date).should == 'green'
  end

  before do
    @date = mock('date')
  end

  after :each do
    SpeakerName.reset_anchors
  end

  def anchor_correct remaining, name, expected
    speaker_name = create_speaker_name name, remaining
    speaker_name.anchor(@date).should == expected
  end

  def create_speaker_name name, remaining
    returning SpeakerName.new('') do |speaker_name|
      speaker_name.stub!(:name).and_return name
      speaker_name.stub!(:remaining).and_return remaining
    end
  end

end
