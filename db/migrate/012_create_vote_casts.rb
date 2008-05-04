class CreateVoteCasts < ActiveRecord::Migration

  def self.up
    create_table :vote_casts, :options => 'default charset=utf8' do |t|
      t.column :vote_id, :integer, :null => false
      t.column :cast, :string, :limit => 12, :null => false
      t.column :cast_count, :integer, :null => false
      t.column :vote_label, :string, :null => false
      t.column :mp_id, :integer
      t.column :party_id, :integer
      t.column :present, :boolean
      t.column :teller, :boolean
    end

    add_index :vote_casts, :vote_id
    add_index :vote_casts, :mp_id
    add_index :vote_casts, :party_id
  end

  def self.down
    drop_table :vote_casts
  end
end
