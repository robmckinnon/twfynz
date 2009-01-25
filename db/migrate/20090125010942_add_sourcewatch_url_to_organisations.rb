class AddSourcewatchUrlToOrganisations < ActiveRecord::Migration
  def self.up
    add_column :organisations, :sourcewatch_url, :string
  end

  def self.down
    remove_column :organisations, :sourcewatch_url
  end
end
