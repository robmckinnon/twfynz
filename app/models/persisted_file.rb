class PersistedFile < ActiveRecord::Base

  before_validation_on_create :default_persisted

  def self.unpersisted_dates publication_status
    files = find_all_by_publication_status_and_persisted(publication_status, false)
    dates = files.collect(&:debate_date).uniq.sort

    if publication_status == 'A'
      finals = find_all_by_publication_status_and_persisted('F', true).collect(&:debate_date).uniq.sort
      dates.delete_if {|d| finals.include? d }
    end
    dates
  end

  def self.unpersisted_files date, publication_status
    find_all_by_debate_date_and_publication_status_and_persisted(date, publication_status, false)
  end

  private

    def default_persisted
      self.persisted = 0 unless self.persisted
    end

end
