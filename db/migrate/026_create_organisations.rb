class CreateOrganisations < ActiveRecord::Migration
  def self.up
    create_table :organisations, :options => 'default charset=utf8' do |t|
      t.column :name, :string
      t.column :url, :string
      t.column :slug, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :organisations
  end
end
