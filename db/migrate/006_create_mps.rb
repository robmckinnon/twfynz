class CreateMps < ActiveRecord::Migration

  def self.up
    create_table :mps, :options => 'default charset=utf8' do |t|
      t.column :elected, :string, :limit => 4, :null => false
      t.column :former, :boolean, :null => false
      t.column :id_name, :string, :limit => 46, :null => false
      t.column :last, :string, :limit => 20, :null => false
      t.column :first, :string, :limit => 25, :null => false
      t.column :title, :string, :limit => 13
      t.column :electorate, :string, :limit => 25
      t.column :member_of_id, :integer
      t.column :img, :string, :limit => 25, :null => false
      t.column :alt, :string, :limit => 20
      t.column :honour, :string, :limit => 3
      t.column :wikipedia_url, :string
      t.column :parliament_url, :string
      t.column :own_website_url, :string
      t.column :party_bio_url, :string
      t.column :image, :string
      t.column :alt_image, :string
      t.column :alt_last, :string
    end

    add_index :mps, :member_of_id
  end

  def self.down
    drop_table :mps
  end
end
