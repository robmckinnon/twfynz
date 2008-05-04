class PersistedFile < ActiveRecord::Base

  before_validation_on_create :default_persisted

  def self.unpersisted_dates publication_status
    PersistedFile.find_all_by_publication_status_and_persisted(publication_status, false).
        collect {|f| f.debate_date}.uniq.sort
  end

  def self.unpersisted_files date, publication_status
    PersistedFile.find_all_by_debate_date_and_publication_status_and_persisted(date, publication_status, false)
  end

  private

    def default_persisted
      self.persisted = 0 unless self.persisted
    end

end
