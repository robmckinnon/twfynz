class CreatePortfolios < ActiveRecord::Migration
  def self.up
    create_table :portfolios, :options => 'default charset=utf8' do |t|
      t.column :beehive_id, :integer
      t.column :portfolio_name, :string, :limit => 82, :null => false
      t.column :url, :string, :limit => 82
      t.column :dpmc_id, :string, :limit => 42
      t.column :dpmc_responsibility, :boolean
    end
  end

  def self.down
    drop_table :portfolios
  end
end
