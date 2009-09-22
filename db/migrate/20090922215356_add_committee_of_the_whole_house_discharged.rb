class AddCommitteeOfTheWholeHouseDischarged < ActiveRecord::Migration
  def self.up
    add_column :bills, :committee_of_the_whole_house_discharged, :date
  end

  def self.down
    remove_column :bills, :committee_of_the_whole_house_discharged
  end
end
