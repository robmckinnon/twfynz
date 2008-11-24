class AddLogoToParties < ActiveRecord::Migration
  def self.up
    add_column :parties, :logo, :string
  end

  def self.down
    remove_column :parties, :logo
  end
end
