class CreateDonations < ActiveRecord::Migration
  def self.up
    create_table :donations do |t|
      t.string :party_name
      t.integer :party_id
      t.string :donor_name
      t.integer :organisation_id
      t.string :donor_address
      t.integer :amount
      t.integer :year

      t.timestamps
    end

    add_index :donations, :party_id
    add_index :donations, :organisation_id
  end

  def self.down
    drop_table :donations
  end
end
