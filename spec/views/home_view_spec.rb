require File.dirname(__FILE__) + '/../spec_helper'

describe "home page" do

  it 'should have page title' do
    template.should_receive(:calendar_nav).any_number_of_times.and_return('')
    # template.should_receive(:render).with(:partial => 'login_form').and_return('')
    # template.should_receive(:render).with(:partial => 'calendar.haml').and_return('')
    template.should_receive(:render).with({:partial=>"parties/vote_matrix_explaination"}).and_return('')
    template.should_receive(:render).with({:object=>nil, :partial=>"parties/vote_matrix"}).and_return('')
    render :template => "home", :layout => "application"
    title = "Helping you track Aotearoa New Zealand's Parliament"
    response.should have_tag("p", title)
  end

end
