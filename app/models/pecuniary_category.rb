# == Schema Information
# Schema version: 21
#
# Table name: pecuniary_categories
#
#  id        :integer(11)   not null, primary key
#  snapshot  :boolean(1)    not null
#  from_date :date          not null
#  to_date   :date          not null
#  name      :string(72)    default(""), not null
#

class PecuniaryCategory < ActiveRecord::Base
end
