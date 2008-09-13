class AddDateIntToContributions < ActiveRecord::Migration
  def self.up
    add_column :contributions, :date_int, :integer

    count = Contribution.count.to_f
    group_size = 100
    index = 0

    start_timing

    while (offset = index * group_size) < count
      log_duration(offset / count) if index > 0
      contributions = Contribution.find(:all, :offset=>offset, :limit=>group_size, :select=>'date, id')
      contributions.each do |contribution|
        contribution.update_attribute('date_int', contribution.date.to_s.tr('-','').to_i) if contribution.date
      end
      index = index.next
    end

  end

  def self.down
    remove_column :contributions, :date_int
  end

  def self.start_timing
    @start = Time.now
  end

  def self.log_duration percentage_complete=nil
    duration = Time.now - @start
    estimated_time = (duration / percentage_complete)
    estimated_remaining = ((estimated_time - duration) / 60).to_i
    if estimated_remaining > 60
      estimated_remaining = (estimated_remaining * 10 / 60) / 10.0
      estimated_remaining = "#{estimated_remaining} hours"
    else
      estimated_remaining = "#{estimated_remaining} mins"
    end
    puts "remaining: #{estimated_remaining}"
  end

end
