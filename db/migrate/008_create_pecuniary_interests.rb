class CreatePecuniaryInterests < ActiveRecord::Migration

  def self.up
    create_table :pecuniary_interests, :options => 'default charset=utf8' do |t|
      t.column :pecuniary_category_id, :integer, :null => false
      t.column :mp_id, :integer, :null => false
      t.column :item, :text, :null => false
    end

    add_index :pecuniary_interests, :pecuniary_category_id
    add_index :pecuniary_interests, :mp_id
  end

  def self.down
    drop_table :pecuniary_interests
  end
end
