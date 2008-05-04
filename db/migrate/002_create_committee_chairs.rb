class CreateCommitteeChairs < ActiveRecord::Migration

  def self.up
    create_table :committee_chairs, :options => 'default charset=utf8' do |t|
      t.column :chairs_id, :integer, :null => false
      t.column :role, :string, :limit => 82, :null => false
    end

    add_index :committee_chairs, :chairs_id
  end

  def self.down
    drop_table :committee_chairs
  end
end
