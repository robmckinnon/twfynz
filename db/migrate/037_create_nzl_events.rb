class CreateNzlEvents < ActiveRecord::Migration
  def self.up
    create_table :nzl_events do |t|
      t.string :title
      t.string :about_type
      t.integer :about_id
      t.string :status
      t.string :nzl_id
      t.string :version_stage
      t.date :version_date
      t.string :version_committee
      t.integer :committee_id
      t.string :information_type
      t.string :legislation_type
      t.integer :year
      t.string :no
      t.date :current_as_at_date
      t.string :link
      t.datetime :publication_date
    end

    add_index :nzl_events, :about_type
    add_index :nzl_events, :about_id
    add_index :nzl_events, :committee_id
  end

  def self.down
    drop_table :nzl_events
  end
end
