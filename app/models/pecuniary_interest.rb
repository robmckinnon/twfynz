# == Schema Information
# Schema version: 21
#
# Table name: pecuniary_interests
#
#  id                    :integer(11)   not null, primary key
#  pecuniary_category_id :integer(11)   not null
#  mp_id                 :integer(11)   not null
#  item                  :text          not null
#

class PecuniaryInterest < ActiveRecord::Base

  belongs_to :pecuniary_category
  belongs_to :mp

end
