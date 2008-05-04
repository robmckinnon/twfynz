class CreateContributions < ActiveRecord::Migration

  def self.up
    create_table :contributions, :options=>"ENGINE=MyISAM", :options => 'default charset=utf8' do |t|
      t.column :spoken_in_id, :integer, :null => false
      t.column :spoken_by_id, :integer
      t.column :type, :string, :null => false
      t.column :speaker, :string
      t.column :on_behalf_of, :string
      t.column :time, :time
      t.column :page, :integer
      t.column :vote_id, :integer
      t.column :text, :text, :null => false
    end

    add_index :contributions, :spoken_in_id
    add_index :contributions, :spoken_by_id
    add_index :contributions, :vote_id

    execute 'create fulltext index speech_index on contributions (text);'
  end

  def self.down
    drop_table :contributions
  end
end
