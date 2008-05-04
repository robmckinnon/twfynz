class CreateBills < ActiveRecord::Migration

  def self.up
    create_table :bills, :options => 'default charset=utf8' do |t|
      t.column :url, :string, :limit => 45
      t.column :bill_no, :string, :limit => 8
      t.column :formerly_part_of_id, :integer
      t.column :member_in_charge_id, :integer, :null => false
      t.column :referred_to_committee_id, :integer
      t.column :type, :string, :limit => 15, :null => false
      t.column :bill_name, :string, :limit => 155, :null => false
      t.column :parliament_url, :string, :null => false
      t.column :parliament_id, :string, :null => false
      t.column :introduction, :date
      t.column :first_reading, :date
      t.column :first_reading_negatived, :boolean, :null => false
      t.column :first_reading_discharged, :date
      t.column :submissions_due, :date
      t.column :sc_reports_interim_report, :date
      t.column :sc_reports, :date
      t.column :sc_reports_discharged, :date
      t.column :consideration_of_report, :date
      t.column :consideration_of_report_discharged, :date
      t.column :second_reading, :date
      t.column :second_reading_negatived, :boolean, :null => false
      t.column :second_reading_discharged, :date
      t.column :committee_of_the_whole_house, :date
      t.column :committal_discharged, :date
      t.column :third_reading, :date
      t.column :royal_assent, :date
      t.column :withdrawn, :date
      t.column :former_name, :string, :limit => 155
      t.column :act_name, :string, :limit => 155
      t.column :description, :text
      t.column :earliest_date, :date, :null => false
    end

    add_index :bills, :referred_to_committee_id
    add_index :bills, :member_in_charge_id
    add_index :bills, :formerly_part_of_id
  end

  def self.down
    drop_table :bills
  end
end
