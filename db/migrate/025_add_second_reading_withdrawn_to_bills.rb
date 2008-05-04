class AddSecondReadingWithdrawnToBills < ActiveRecord::Migration
  def self.up
    add_column :bills, :second_reading_withdrawn, :date
  end

  def self.down
    remove_column :bills, :second_reading_withdrawn
  end
end
