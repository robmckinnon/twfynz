require File.dirname(__FILE__) + '/../spec_helper'

describe BillsController do

  it 'should handle show_bill when bill is nill' do
    @controller.stub!(:get_bill).and_return(nil)
    get :show_bill, :bill_url => 'doesnt_exist'
    response.should render_template("bills/invalid_bill")
    response.headers["Status"].should == "404 Not Found"
  end
end
