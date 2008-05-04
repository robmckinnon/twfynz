class CreateDebates < ActiveRecord::Migration

  def self.up
    create_table :debates, :options=>"ENGINE=MyISAM", :options => 'default charset=utf8' do |t|
      t.column :date, :date, :null => false
      t.column :debate_index, :integer, :null => false
      t.column :publication_status, :string, :limit => 1, :null => false
      t.column :source_url, :string
      t.column :type, :string, :null => false
      t.column :hansard_volume, :integer
      t.column :start_page, :integer
      t.column :name, :string, :null => false
      t.column :css_class, :string, :null => false
      t.column :debate_id, :integer
      t.column :about_type, :string
      t.column :about_id, :integer
      t.column :about_index, :integer
      t.column :answer_from_type, :string
      t.column :answer_from_id, :integer
      t.column :oral_answer_no, :integer
      t.column :re_oral_answer_no, :integer
    end

    add_index :debates, :debate_id
  end

  def self.down
    drop_table :debates
  end
end
