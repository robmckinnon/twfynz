class CreatePecuniaryCategories < ActiveRecord::Migration
  def self.up
    create_table :pecuniary_categories, :options => 'default charset=utf8' do |t|
      t.column :snapshot, :boolean, :null => false
      t.column :from_date, :date, :null => false
      t.column :to_date, :date, :null => false
      t.column :name, :string, :limit => 72, :null => false
    end
  end

  def self.down
    drop_table :pecuniary_categories
  end
end
