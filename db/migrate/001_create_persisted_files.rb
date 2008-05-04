class CreatePersistedFiles < ActiveRecord::Migration
  def self.up
    create_table :persisted_files, :options => 'default charset=utf8' do |t|
      t.column :debate_date, :date
      t.column :publication_status, :string, :limit => 1
      t.column :oral_answer, :boolean
      t.column :downloaded, :boolean
      t.column :download_date, :date
      t.column :persisted, :boolean
      t.column :persisted_date, :date
      t.column :file_name, :string
      t.column :parliament_name, :string
      t.column :parliament_url, :string
    end
  end

  def self.down
    drop_table :persisted_files
  end
end
