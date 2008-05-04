# == Schema Information
# Schema version: 21
#
# Table name: ministers
#
#  id                 :integer(11)   not null, primary key
#  responsible_for_id :integer(11)   not null
#  title              :string(82)    default(""), not null
#

class Minister < ActiveRecord::Base

  belongs_to :portfolio, :foreign_key => 'responsible_for_id'

  def self.from_name name
    name = name.sub('Acting ', '').strip.downcase.to_latin.gsub('’',"'")
    Minister.find(:all).select {|m| m.title.downcase == name}.first
  end

end
