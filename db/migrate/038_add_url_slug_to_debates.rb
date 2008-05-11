class AddUrlSlugToDebates < ActiveRecord::Migration
  def self.up
    add_column :debates, :url_slug, :string

    add_index :debates, :url_slug
  end

  def self.down
    remove_column :debates, :url_slug
  end
end
