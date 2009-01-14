class PersistedFile < ActiveRecord::Base

  before_validation_on_create :default_persisted

  class << self

    def set_all_indexes_on_date
      dates = all.collect(&:debate_date).uniq.sort
      dates.each do |date|
        puts "setting indexes for: #{date}"
        set_indexes_on_date date, 'U'
        set_indexes_on_date date, 'A'
        set_indexes_on_date date, 'F'
      end
    end

    def set_indexes_on_date debate_date, publication_status
      files = find_all_by_debate_date_and_publication_status(debate_date, publication_status)
      unless files.empty?
        files = files.sort_by(&:id)
        files.each_with_index do |file, index|
          file.index_on_date = (index + 1)
          file.save!
        end
      end
    end

    def unpersisted_dates publication_status
      files = find_all_by_publication_status_and_persisted(publication_status, false)
      dates = files.collect(&:debate_date).uniq.sort

      if publication_status == 'A'
        finals = find_all_by_publication_status_and_persisted('F', true).collect(&:debate_date).uniq.sort
        dates.delete_if {|d| finals.include? d }
      end
      dates
    end

    def unpersisted_files date, publication_status
      find_all_by_debate_date_and_publication_status_and_persisted(date, publication_status, false)
    end
  end

  def normalized_name
    # 2008/12/11/advance/49HansD_20081211_00000896-Employment-Relations-Amendment-Bill-Second.htm
    if index_on_date
      date = file_name[/\d\d\d\d\/\d\d\/\d\d/]
      type = file_name[/Hans(.)/, 1]
      name = file_name[/\d+-([\D].+.htm)$/, 1]

      index = index_on_date < 10 ? "00#{index_on_date}" : (index_on_date < 100 ? "0#{index_on_date}" : index_on_date.to_s)
      "#{date}/#{type}/#{index}_#{name}"
    else
      raise 'need to set index_on_date before calling normalized_name ' + self.inspect
    end
  end
  private
    def default_persisted
      self.persisted = 0 unless self.persisted
    end
end
