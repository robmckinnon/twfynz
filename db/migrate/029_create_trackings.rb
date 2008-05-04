class CreateTrackings < ActiveRecord::Migration
  def self.up
    create_table :trackings do |t|
      t.column :item_type, :string
      t.column :item_id, :integer
      t.column :user_id, :integer
      t.column :tracking_on, :boolean
      t.column :email_alert, :boolean
      t.column :include_in_feed, :boolean
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :trackings
  end
end
