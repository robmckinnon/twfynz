class AddWikipediaUrlToOrganisations < ActiveRecord::Migration
  def self.up
    add_column :organisations, :wikipedia_url, :string
  end

  def self.down
    remove_column :organisations, :wikipedia_url
  end
end
