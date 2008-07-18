class AddPlainFormerNameToBills < ActiveRecord::Migration
  def self.up
    add_column :bills, :plain_former_name, :string
    Bill.reset_column_information

    Bill.find(:all).each do |bill|
      bill.populate_plain_former_name
      bill.save!
    end

    add_index :bills, :former_name
    add_index :bills, :plain_former_name
  end

  def self.down
    remove_index :bills, :former_name
    remove_index :bills, :plain_former_name

    remove_column :bills, :plain_former_name
  end
end
