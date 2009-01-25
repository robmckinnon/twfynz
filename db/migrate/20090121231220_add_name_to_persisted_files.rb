class AddNameToPersistedFiles < ActiveRecord::Migration
  def self.up
    add_column :persisted_files, :name, :string
    add_index :persisted_files, :name
  end

  def self.down
    remove_column :persisted_files, :name
  end
end
