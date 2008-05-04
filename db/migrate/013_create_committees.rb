class CreateCommittees < ActiveRecord::Migration
  def self.up
    create_table :committees, :options => 'default charset=utf8' do |t|
      t.column :clerk_category_id, :integer
      t.column :committee_type, :string, :limit => 19, :null => false
      t.column :committee_name, :string, :limit => 46, :null => false
      t.column :url, :string, :limit => 46, :null => false
      t.column :description, :string, :limit => 234
      t.column :former, :boolean, :null => false
    end
  end

  def self.down
    drop_table :committees
  end
end
