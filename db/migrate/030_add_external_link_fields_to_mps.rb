class AddExternalLinkFieldsToMps < ActiveRecord::Migration

  def self.up
    # add_column :mps, :wikipedia_url, :string
    # add_column :mps, :parliament_url, :string
    # add_column :mps, :own_website_url, :string
    # add_column :mps, :party_bio_url, :string
  end

  def self.down
    # remove_column :mps, :wikipedia_url
    # remove_column :mps, :parliament_url
    # remove_column :mps, :own_website_url
    # remove_column :mps, :party_bio_url
  end
end
