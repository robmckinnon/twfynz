class AddWikipediaUrlToParties < ActiveRecord::Migration
  def self.up
    add_column :parties, :wikipedia_url, :string
  end

  def self.down
    remove_column :parties, :wikipedia_url, :string
  end
end
