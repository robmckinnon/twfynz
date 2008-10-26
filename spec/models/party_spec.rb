require File.dirname(__FILE__) + '/../spec_helper'

def party_params
  { :name => 'The Greens, The Green Party of Aotearoa New Zealand',
    :registered => '1995-08-17',
    :abbreviation => 'Green Party',
    :url => 'http://www.greens.org.nz/',
    :colour => "065222",
    :short => 'Green'
  }
end

def party_mp_params
  { :first => 'Rod',
    :last => 'Donald',
    :elected => '2000',
    :former => 0,
    :id_name => 'rod_donald',
    :img => 'rod.png'}
end

describe Party, 'in general' do

  assert_model_has_many :donations
  assert_model_has_many :parliament_parties

  it 'should have mps' do
    party = Party.new party_params
    party.save!
    mp = Mp.new party_mp_params.merge(:member_of_id=>party.id)
    mp.save!
    party.mps.size.should == 1
    party.mps.first.id.should == mp.id

    Party.delete_all
    Mp.delete_all
  end
end
