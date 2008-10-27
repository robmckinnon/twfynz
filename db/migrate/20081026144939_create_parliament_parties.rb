class CreateParliamentParties < ActiveRecord::Migration
  def self.up
    create_table :parliament_parties, :options => 'default charset=utf8' do |t|
      t.integer :parliament_id
      t.integer :party_id
      t.text :parliament_description
      t.text :in_parliament_text
      t.text :parliament_agreements_text
      t.string :agreements_file
      t.string :parliament_url
      t.string :wikipedia_url
      t.integer :party_votes_count
      t.integer :bill_final_reading_party_votes_count
    end

    add_index :parliament_parties, :parliament_id
    add_index :parliament_parties, :party_id
  end

  def self.down
    drop_table :parliament_parties
  end
end
