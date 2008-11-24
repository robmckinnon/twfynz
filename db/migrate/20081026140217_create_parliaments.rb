class CreateParliaments < ActiveRecord::Migration
  def self.up
    create_table :parliaments do |t|
      t.string :ordinal
      t.date :commission_opening_date
      t.integer :commission_opening_debate_id
      t.date :dissolution_date
      t.string :wikipedia_url
      t.integer :party_votes_count
      t.integer :bill_final_reading_party_votes_count
    end
  end

  def self.down
    drop_table :parliaments
  end
end
