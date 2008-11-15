class AddParliamentIdToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :parliament_id, :integer

    add_index :members, :parliament_id
  end

  def self.down
    remove_column :members, :parliament_id
  end
end
