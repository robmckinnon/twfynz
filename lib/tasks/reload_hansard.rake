require 'fileutils'

namespace :kiwimp do

  desc 're-download files & remove old database data for dates=yyyy-mm-dd,...'
  task :redownload_hansard => :environment do
    if ENV['dates']
      dates = ENV['dates'].split(',').collect do |date|
        begin
          Date.parse(date)
        rescue e
          puts "couldn't parse date: " + date
        end
      end
      require File.dirname(__FILE__) + '/../hansard_downloader.rb'

      dates.each {|date| redownload_date date}
    else
      puts 'you need to specify dates, e.g. rake kiwimp:redownload_hansard dates=2007-06-14,2007-06-20'
    end
  end

  desc 're-load file for date=yyyy-mm-dd and status=[F|A|u]'
  task :reload_hansard => [:environment, :unload_hansard, :load_hansard] do
  end

  desc 'unload hansard for date=yyyy-mm-dd and status=[F|A|u]'
  task :unload_hansard => :environment do
    if ENV['date']
      publication_status = ENV['status'] ? ENV['status'] : 'F'
      date = begin
               Date.parse(ENV['date'])
             rescue e
               puts "couldn't parse date: " + date
             end
      unload_date date, publication_status
    else
      puts 'you need to specify date and status, e.g. rake kiwimp:reload_hansard date=2007-06-14 status=F'
    end
  end

  def unload_date date, publication_status
    delete_debates date, publication_status
    records = PersistedFile.find_all_by_debate_date_and_publication_status(date, publication_status)
    puts 'setting ' + records.size.to_s + ' persisted file records to "unpersisted"'
    records.each {|record| record.persisted = false; record.save!}
  end

  def redownload_date date
    data_path = File.join(RAILS_ROOT, 'data', date.strftime('%Y/%m/%d'))

    if (to_delete = get_directory_to_delete(data_path))
      publication_status = to_delete[0..0].upcase

      original, backup = move_original_download(data_path, to_delete, date)
      delete_debates date, publication_status
      delete_records date, publication_status

      HansardDownloader.new.download(RAILS_ROOT + '/data/',
          (to_delete == 'uncorrected'),
          (update_of_persisted_files_table=true), date)

      warn_if_problem original, date, publication_status, backup
    else
      puts 'no directory found to redownload at: ' + data_path
    end
  end

  def get_directory_to_delete data_path
    directories = Dir.glob(data_path+'/*').collect do |f|
      f.split('/').last
    end
    if directories.include? 'final'
      'final'
    elsif directories.include? 'advance'
      'advance'
    elsif directories.include? 'uncorrected'
      'uncorrected'
    else
      nil
    end
  end

  def move_original_download data_path, to_delete, date
    original = File.join data_path, to_delete
    backup = original + '_' + Date.today.strftime('%Y_%m_%d')
    puts 'moving ' + original + ' to ' + backup
    FileUtils.move original, backup
    return original, backup
  end

  def delete_debates date, publication_status
    debates = Debate.find_all_by_date_and_publication_status(date, publication_status)
    puts 'destroying ' + debates.size.to_s + ' debates' if debates
    debates.each { |debate| debate.destroy }
  end

  def delete_records date, publication_status
    records = PersistedFile.find_all_by_debate_date_and_publication_status(date, publication_status)
    puts 'destroying ' + records.size.to_s + ' persisted file records' if records
    records.each { |record| record.destroy }
  end

  def warn_if_problem original, date, publication_status, backup
    if File.exists?(original)
      records = PersistedFile.find_all_by_debate_date_and_publication_status(date, publication_status)
      if records.size == 0
        raise 'expected new rows to be in persisted_files, but they are not there! backup is: ' + backup
      else
        puts 'created ' + records.size.to_s + ' persisted file records; to load use rake kiwimp:load_hansard'
      end
    else
      raise 'original directory has not redownloaded, backup is: ' + backup
    end
  end

end
