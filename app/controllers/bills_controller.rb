class BillsController < ApplicationController

  caches_action :index, :negatived, :assented, :show_bill_atom, :show_bill

  layout "bills_layout", :except => 'show_bill_atom'

  before_filter :find_bill, :only => [:show_bill, :show_bill_atom]

  def index
    @bills_on = true
    @bills_current = Bill.find_all_current.sort_by(&:bill_name)
    # @bills_current_by_event = Bill.find_all_current.sort_by(&:last_event_name).in_groups_by(&:last_event_name)
    # @bills_with_debates = Bill.find_all_current.group_by &:url
    # @letter_to_bills = @bills_with_debates.keys.group_by {|b| b[0..0]}
    # View code:
    # %p= render(:partial => 'bill_group_link', :collection => @letter_to_bills.keys.sort, :locals => {:prefix => ''})
          # = render(:partial => 'bill_group', :collection => @letter_to_bills.keys.sort, :locals => {:letter_to_bills => @letter_to_bills, :bills => @bills_with_debates, :prefix => '', :first => @letter_to_bills.keys.sort[0]})
  end

  def negatived
    @bills_on = true
    @bills_negatived = Bill.find_all_negatived.group_by(&:url)
    @letter_to_negatived = @bills_negatived.keys.group_by {|b| b[0..0]}
  end

  def assented
    @bills_on = true
    @bills_assented = Bill.find_all_assented.group_by(&:url)
    @letter_to_assented = @bills_assented.keys.group_by {|b| b[0..0]}
  end

  def show_bill_submissions
    @bills_on = true
    name = params[:bill_url]

    @bill = Bill.find_by_url(name)
    @name_to_submissions = Submission.find_all_by_business_item(@bill).group_by do |submission|
      if submission.submitter
        submission.submitter.name
      else
        submission.submitter_name
      end
    end
  end

  def show_bill_format
    format.html { show_bill }
    format.atom { show_bill_atom }
  end

  def show_bill_atom
    params[:format] = 'atom'
    @bill_events = @bill.bill_events.sort_by(&:date).reverse
  end

  def show_bill
    @admin = admin?
    @bills_on = true
    @tracking = get_tracking @bill
    @trackings = Tracking.all_for_item(@bill, current_user)
    unless read_fragment(:action => 'show_bill' )
      @hash = params
      @submissions_count = Submission.count_by_business_item @bill
      @top_level_bill_events = @bill.top_level_bill_events
      @have_votes = @bill.have_votes?
      @missing_votes = @bill.is_missing_votes?
    end
  end

  def find_bill
    name = params[:bill_url]
    unless (@bill = get_bill(name))
      render(:template => 'bills/invalid_bill', :status => 404)
    end
  end

  protected

    def get_bill name
      if read_fragment(:action => 'show_bill' )
        @bill = Bill.find_by_url(name)
      else
        @bill = Bill.find_by_url(name, :include => [:submission_dates,
            :member_in_charge, :referred_to_committee,
            :sub_debates, {:debate_topics => :debate}])
      end
    end

    def get_tracking bill
      tracking = Tracking.new
      tracking.item = bill

      if (user_tracking = Tracking.from_user_and_item(current_user, bill))
        tracking.tracking_on = user_tracking.tracking_on
      else
        tracking.tracking_on = false
      end
      tracking
    end
end
