class CreateSubmissions < ActiveRecord::Migration
  def self.up
    create_table :submissions, :options => 'default charset=utf8' do |t|
      t.column :submitter_name, :string
      t.column :submitter_url, :string
      t.column :business_item_name, :string
      t.column :committee_id, :integer
      t.column :date, :date
      t.column :evidence_url, :string
      t.column :business_item_type, :string
      t.column :business_item_id, :integer
      t.column :is_from_organisation, :boolean
      t.column :submitter_type, :string
      t.column :submitter_id, :integer
    end
  end

  def self.down
    drop_table :submissions
  end
end
