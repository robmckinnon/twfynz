require File.dirname(__FILE__) + '/../../spec_helper'

describe "signup page" do

  it 'should have form' do
    # template.should_receive(:calendar_nav).twice.and_return('')
    render :template => "/user/signup"

    response.should have_tag("#individual_signup")
    response.should have_tag("#organisation_signup")
  end

end
