class AddAlternateNamesToOrganisations < ActiveRecord::Migration

  def self.up
    add_column :organisations, :alternate_names, :string

    Organisation.reset_column_information

    Organisation.find(:all).each do |organisation|
      organisation.alternate_names = ''
      organisation.save!
    end
  end

  def self.down
    remove_column :organisations, :alternate_names
  end
end
