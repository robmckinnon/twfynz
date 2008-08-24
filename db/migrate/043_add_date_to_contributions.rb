class AddDateToContributions < ActiveRecord::Migration
  def self.up
    add_column :contributions, :date, :date

    Contribution.find(:all, :include => :spoken_in).each do |contribution|
      contribution.save! # populates date in before_validation filter
    end

    add_index :contributions, :date
  end

  def self.down
    remove_column :contributions, :date
  end
end
