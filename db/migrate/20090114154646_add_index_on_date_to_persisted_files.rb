class AddIndexOnDateToPersistedFiles < ActiveRecord::Migration

  def self.up
    add_column :persisted_files, :index_on_date, :integer
  end

  def self.down
    remove_column :persisted_files, :index_on_date
  end
end
