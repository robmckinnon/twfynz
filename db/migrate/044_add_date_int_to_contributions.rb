class AddDateIntToContributions < ActiveRecord::Migration
  def self.up
    add_column :contributions, :date_int, :integer

    Contribution.find(:all, :include => :spoken_in).each do |contribution|
      contribution.save! # populates date in before_validation filter
    end
  end

  def self.down
    remove_column :contributions, :date_int
  end
end
