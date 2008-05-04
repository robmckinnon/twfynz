class CreateSubmissionDates < ActiveRecord::Migration

  def self.up
    create_table :submission_dates, :options => 'default charset=utf8' do |t|
      t.column :parliament_url, :string, :limit => 255, :null => false
      t.column :committee_id, :integer
      t.column :bill_id, :integer, :null => false
      t.column :date, :date
      t.column :title, :string, :limit => 255, :null => false
      t.column :details, :string, :limit => 255, :null => false
    end

    add_index :submission_dates, :committee_id
    add_index :submission_dates, :bill_id
  end

  def self.down
    drop_table :submission_dates
  end
end
