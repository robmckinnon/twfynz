class AddIndexToMpsIdName < ActiveRecord::Migration
  def self.up
    add_index :mps, :id_name
  end

  def self.down
    remove_index :mps, :id_name
  end
end
