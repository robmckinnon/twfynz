class AddDateIntToContributions < ActiveRecord::Migration
  def self.up
    add_column :contributions, :date_int, :integer

    Contribution.find(:all, :include => :spoken_in).each do |contribution|
      if contribution.spoken_in
        contribution.update_attribue('date_int', contribution.spoken_in.date.to_s.tr('-','').to_i)
      end
    end
  end

  def self.down
    remove_column :contributions, :date_int
  end
end
