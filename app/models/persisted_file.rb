require 'fileutils'

class PersistedFile < ActiveRecord::Base

  before_validation_on_create :default_persisted

  class << self

    def data_path
      RAILS_ROOT + '/data2/'
    end

    def file_name(date, status, name)
      date.strftime('%Y/%m/%d')+'/'+status+'/'+name
    end

    def file_path(date, status, name)
      data_path + file_name(date, status, name)
    end

    def exists? date, status, name
      File.exists? file_path(date, status, name)
    end

    def publication_status_name status_code
      if status_code[/A/]
        'advance'
      elsif status_code[/U/]
        'uncorrected'
      elsif status_code[/F/]
        'final'
      end
    end

    def publication_status_code status
      if status[/advance/]
        'A'
      elsif status[/uncorrected/]
        'U'
      elsif status[/final/]
        'F'
      end
    end

    def add_new record, contents
      make_directory record.debate_date, record.publication_status_name

      record.file_name = record.make_file_name
      puts 'writing: ' + record.file_name
      filepath = record.make_file_path

      File.open(filepath, 'w') do |file|
        file.write(contents)
        record.downloaded = true
        record.download_date = Date.today
      end
      record.save!
    end

    def add_if_missing record
      debate_date = record.debate_date
      filename = record.make_file_name
      existing = find_by_file_name(filename)

      unless existing
        filepath = record.make_file_path
        time = File.new(filepath).ctime
        download_date = Date.new(time.year, time.month, time.day).to_s

        record.file_name = filename
        record.downloaded = true
        record.download_date = download_date

        puts "adding #{filename} to persisted_files"
        record.save!
      end
    end

    def add_non_downloaded record
      record.downloaded = false
      record.save!
    end

    def make_directory date, publication_status
      make_dir data_path
      make_dir data_path + date.strftime('%Y')
      make_dir data_path + date.strftime('%Y/%m')
      make_dir data_path + date.strftime('%Y/%m/%d')
      make_dir data_path + date.strftime('%Y/%m/%d')+'/'+publication_status
    end

    def make_dir directory
      Dir.mkdir directory unless File.exists? directory
    end

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
          unless file.name
            file.populate_name
            download_file = PersistedFile.data_path + file.file_name
            storage_file = PersistedFile.data_path + file.name
            FileUtils.cp download_file, storage_file
          end
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

  def make_file_path
    PersistedFile.file_path(debate_date, publication_status_name, parliament_file_name)
  end

  def make_file_name
    PersistedFile.file_name(debate_date, publication_status_name, parliament_file_name)
  end

  def exists?
    PersistedFile.exists?(debate_date, publication_status_name, parliament_file_name)
  end

  def publication_status_name
    PersistedFile.publication_status_name self.publication_status
  end

  def parliament_file_name
    parliament_url.split('/').last
  end

  def populate_name
    if index_on_date
      begin
        date = file_name[/\d\d\d\d\/\d\d\/\d\d/]
        type = file_name[/Hans(.)/, 1]
        name = file_name[/\d+-([\D].+.htm)$/, 1]

        index = index_on_date < 10 ? "00#{index_on_date}" : (index_on_date < 100 ? "0#{index_on_date}" : index_on_date.to_s)
        self.name = "#{date}/#{type}/#{index}_#{name}"
      rescue Exception => e
        puts "unexpected file_name syntax: #{file_name}"
        raise e
      end
    else
      raise 'need to set index_on_date before calling normalized_name ' + self.inspect
    end
  end

  def set_publication_status status_name
    self.publication_status = PersistedFile.publication_status_code(status_name)
  end

  private

    def default_persisted
      self.persisted = 0 unless self.persisted
    end
end
