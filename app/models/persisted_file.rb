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

    def publication_status_code status
      if status.include? 'advance'
        'A'
      elsif status.include? 'uncorrected'
        'U'
      elsif status.include? 'final'
        'F'
      end
    end

    def add_new date, status, name, parliament_name, url, downloading_uncorrected, contents
      make_directory date, status
      filename = file_name(date, status, name)
      status_code = publication_status_code(status)

      record = new({
          :debate_date => date,
          :publication_status => status_code,
          :oral_answer => downloading_uncorrected,
          :file_name => filename,
          :parliament_name => parliament_name,
          :parliament_url => url
      })
      puts 'writing: ' + record.file_name
      filepath = file_path(date, status, name)
      File.open(filepath, 'w') do |file|
        file.write(contents)
        record.downloaded = true
        record.download_date = Date.today
      end
      record.save!
    end

    def add_if_missing date, status, name, parliament_name, url, downloading_uncorrected
      filename = file_name(date, status, name)
      existing = find_by_file_name(filename)

      unless existing
        filepath = file_path(date, status, name)
        time = File.new(filepath).ctime
        download_date = Date.new(time.year, time.month, time.day).to_s
        status_code = publication_status_code(status)

        record = new({
            :debate_date => date,
            :publication_status => status_code,
            :oral_answer => downloading_uncorrected,
            :file_name => filename,
            :parliament_name => parliament_name,
            :parliament_url => url,
            :downloaded => true,
            :download_date => download_date
        })
        puts "adding #{filename} to persisted_files"
        record.save!
      end
    end

    def add_non_downloaded date, parliament_name, url, downloading_uncorrected
      record = new({
          :debate_date => date,
          :downloaded => false,
          :oral_answer => downloading_uncorrected,
          :parliament_name => parliament_name,
          :parliament_url => url
      })
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
  private

    def default_persisted
      self.persisted = 0 unless self.persisted
    end
end
