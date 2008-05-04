class CommitteeChair < ActiveRecord::Base

  belongs_to :committee, :foreign_key => 'chairs_id'
  has_many :oral_answers, :as => :answer_from

  def self.from_name name
    CommitteeChair.find_by_role name
  end

  def title
    role
  end
end
