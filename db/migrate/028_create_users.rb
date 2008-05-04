class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :options => 'default charset=utf8' do |t|
      t.column :type, :string
      t.column :login, :string
      t.column :hashed_password, :string
      t.column :email, :string
      t.column :salt, :string
      t.column :blog_url, :string
      t.column :site_url, :string
      t.column :email_confirmed, :boolean
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :users
  end
end
