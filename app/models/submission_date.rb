class SubmissionDate < ActiveRecord::Base
  belongs_to :bill
  belongs_to :committee
end
