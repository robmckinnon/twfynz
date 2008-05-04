class AddPlainBillNameToBills < ActiveRecord::Migration
  def self.up
    add_column :bills, :plain_bill_name, :string
    Bill.reset_column_information

    Bill.find(:all).each do |bill|
      bill.populate_plain_bill_name
      bill.save!
    end

    add_index :bills, :bill_name
    add_index :bills, :plain_bill_name
  end

  def self.down
    remove_index :bills, :bill_name
    remove_index :bills, :plain_bill_name

    remove_column :bills, :plain_bill_name
  end
end
