class AddUrlSlugToDebates < ActiveRecord::Migration
  def self.up
    add_column :debates, :url_slug, :string
    add_column :debates, :url_category, :string

    add_index :debates, :url_slug
    add_index :debates, :url_category
  end

  def self.down
    remove_column :debates, :url_slug
    remove_column :debates, :url_category
  end
end
