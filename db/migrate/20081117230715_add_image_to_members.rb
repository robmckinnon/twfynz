class AddImageToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :image, :string
  end

  def self.down
    remove_column :members, :image
  end
end
