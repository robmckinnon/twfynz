class SubmissionDate < ActiveRecord::Base
  belongs_to :bill
  belongs_to :committee

  def self.find_live_bill_submissions
    submissions = find(:all, :include => :bill).select{|sd| sd.date >= Date::today}
    submissions.sort {|a,b| ((a.date <=> b.date) == 0) ? a.title <=> b.title : a.date <=> b.date }
  end
end
