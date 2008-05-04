class AddCountOfMentionsToOrganisations < ActiveRecord::Migration
  def self.up
    add_column :organisations, :count_of_mentions, :integer
    Organisation.reset_column_information
    # Organisation.find(:all).each do |organisation|
      # organisation.populate_count_of_mentions
      # organisation.save!
    # end
  end

  def self.down
    remove_column :organisations, :count_of_mentions
  end
end
