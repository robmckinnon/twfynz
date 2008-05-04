class CreateMinisters < ActiveRecord::Migration

  def self.up
    create_table :ministers, :options => 'default charset=utf8' do |t|
      t.column :responsible_for_id, :integer, :null => false
      t.column :title, :string, :limit => 82, :null => false
    end

    add_index :ministers, :responsible_for_id
  end

  def self.down
    drop_table :ministers
  end
end
