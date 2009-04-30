class SubmissionDate < ActiveRecord::Base
  belongs_to :bill
  belongs_to :committee

  def self.find_live_bill_submissions
    submissions = find(:all, :include => :bill).select{|sd| sd.date >= Date::today}
    bills = submissions.collect(&:bill_id).uniq
    unique = []
    submissions.each do |submission|
      if bills.include? submission.bill_id
        unique << submission
        bills.delete(submission.bill_id)
      end
    end
    unique.sort {|a,b| ((a.date <=> b.date) == 0) ? a.title <=> b.title : a.date <=> b.date }
  end
end
