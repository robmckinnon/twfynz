# == Schema Information
# Schema version: 21
#
# Table name: bills
#
#  id                                 :integer(11)   not null, primary key
#  url                                :string(45)    
#  bill_no                            :string(8)     
#  formerly_part_of_id                :integer(11)   
#  member_in_charge_id                :integer(11)   not null
#  referred_to_committee_id           :integer(11)   
#  type                               :string(15)    default(""), not null
#  bill_name                          :string(155)   default(""), not null
#  parliament_url                     :string(255)   default(""), not null
#  parliament_id                      :string(255)   default(""), not null
#  introduction                       :date          
#  first_reading                      :date          
#  first_reading_negatived            :boolean(1)    not null
#  first_reading_discharged           :date          
#  submissions_due                    :date          
#  sc_reports_interim_report          :date          
#  sc_reports                         :date          
#  sc_reports_discharged              :date          
#  consideration_of_report            :date          
#  consideration_of_report_discharged :date          
#  second_reading                     :date          
#  second_reading_negatived           :boolean(1)    not null
#  second_reading_discharged          :date          
#  committee_of_the_whole_house       :date          
#  committal_discharged               :date          
#  third_reading                      :date          
#  royal_assent                       :date          
#  withdrawn                          :date          
#  former_name                        :string(155)   
#  act_name                           :string(155)   
#  description                        :text          
#  earliest_date                      :date          not null
#

class PrivateBill < Bill

end
