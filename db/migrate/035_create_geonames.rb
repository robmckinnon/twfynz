class CreateGeonames < ActiveRecord::Migration
  def self.up
    create_table :geonames, :options => 'default charset=utf8' do |t|
      t.column :geonameid, :integer
      t.column :name, :string
      t.column :first_word_in_name, :string
      t.column :asciiname, :string
      t.column :alternatenames, :text
      t.column :latitude, :decimal, :precision => 10, :scale => 7
      t.column :longitude, :decimal, :precision => 10, :scale => 7
      t.column :feature_class, :string
      t.column :feature_code, :string
      t.column :country_code, :string
      t.column :cc2, :string
      t.column :admin1_code, :string
      t.column :admin2_code, :string
      t.column :admin3_code, :string
      t.column :admin4_code, :string
      t.column :population, :integer
      t.column :elevation, :integer
      t.column :gtopo30, :integer
      t.column :timezone, :string
      t.column :modification_date, :date
      t.column :slug, :string
      t.column :count_of_mentions, :integer
    end

    add_index :geonames, :first_word_in_name
  end

  def self.down
    drop_table :geonames
  end
end
