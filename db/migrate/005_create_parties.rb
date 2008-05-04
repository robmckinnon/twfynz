class CreateParties < ActiveRecord::Migration
  def self.up
    create_table :parties, :options => 'default charset=utf8' do |t|
      t.column :short, :string, :null => false
      t.column :name, :string
      t.column :vote_name, :string
      t.column :registered, :date
      t.column :abbreviation, :string
      t.column :url, :string
      t.column :colour, :string, :limit => 6
    end
  end

  def self.down
    drop_table :parties
  end
end
