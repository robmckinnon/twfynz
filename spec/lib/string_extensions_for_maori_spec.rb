require File.dirname(__FILE__) + '/../spec_helper'

describe String, "to_latin" do

  it 'should convert Māori to Maori' do
    'Māori'.to_latin.should == 'Maori'
  end

end
