require File.dirname(__FILE__) + '/../spec_helper'

describe BillsController do

  shared_examples_for "renders 404 when bill not found" do
    it 'should show 404' do
      @controller.should_receive(:get_bill).with(@name).and_return(nil)
      get @action, :bill_url => @name
      response.should render_template("bills/invalid_bill")
      response.status.should == "404 Not Found"
    end
  end

  shared_examples_for "renders bill in appropriate format" do
    it 'should render bill' do
      @controller.should_receive(:get_bill).with(@name).and_return mock('bill')
      @controller.should_receive(@action)
      puts @action.to_s
      get @action, :bill_url => @name
    end
  end

  describe 'when show_bill requested' do
    describe 'with html format' do
      before do
        @name = 'electoral_finance'
        @action = :show_bill
      end
      it_should_behave_like "renders bill in appropriate format"
      it_should_behave_like "renders 404 when bill not found"
    end
    describe 'with atom format' do
      before do
        @name = 'electoral_finance'
        @action = :show_bill_atom
      end
      # it_should_behave_like "renders bill in appropriate format"
      it_should_behave_like "renders 404 when bill not found"
    end
  end
end
