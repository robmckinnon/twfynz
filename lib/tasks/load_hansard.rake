namespace :kiwimp do

  desc 'download hansard from parliament.nz'
  task :download_hansard => :environment do
    require File.dirname(__FILE__) + '/../hansard_downloader.rb'
    data_path = RAILS_ROOT + '/data/'
    HansardDownloader.new.download data_path, (uncorrected=true), (update_of_persisted_files_table=false)
    HansardDownloader.new.download data_path, (uncorrected=false), (update_of_persisted_files_table=false)
  end

  desc 'DEV USE ONLY: mark ALL files as not persisted in persisted_files table'
  task :unpersist => :environment do
    count = 0
    PersistedFile.find(:all).each do |f|
      if f.persisted
        count += 1
        f.persisted = false
        f.save!
      end
    end
    if count > 0
      puts 'changed ' + count.to_s + ' records in persisted_files to not persisted'
    else
      puts 'no records in persisted_files required changing'
    end
  end

  desc 'load hansard from /data'
  # task :load_hansard => [:environment, :load_questions] do
  task :load_hansard => [:environment] do
    # require File.dirname(__FILE__) + '/../hansard_parser.rb'
    sleep_seconds = ENV['sleep'].to_i if ENV['sleep']
    persist 'A', sleep_seconds
    persist 'F', sleep_seconds
  end

  # desc 'load questions from /data'
  task :load_questions => :environment do
    require File.dirname(__FILE__) + '/../hansard_parser.rb'
    data_path = RAILS_ROOT + '/data/'
    dates = PersistedFile.unpersisted_dates 'U'

    dates.each do |date|
      files = PersistedFile.unpersisted_files(date, 'U').sort_by(&:file_name)
      oral_answers = nil

      files.each_with_index do |file, index|
        puts 'parsing: data/' + file.file_name
        file_path = data_path + file.file_name
        url = file.parliament_url
        parser = HansardParser.new(file_path, url)
        oral_answers = parser.parse_oral_answer(index+1, oral_answers)
      end

      puts 'saving: ' + oral_answers.class.name
      oral_answers.save!
      puts 'persisted: ' + date.to_s
      files.each do |f|
        f.persisted = true
        f.save!
      end
    end
  end
end

def persist publication_status, sleep_seconds
  dates = PersistedFile.unpersisted_dates publication_status

  dates.each do |date|
    if date.year == 2005
      if date.month > 9
        persist_date date, publication_status, sleep_seconds
      end
    elsif date.year > 2005
      persist_date date, publication_status, sleep_seconds
    end
  end
end

def persist_date date, publication_status, sleep_seconds=nil
  data_path = RAILS_ROOT + '/data/'
  files = PersistedFile.unpersisted_files(date, publication_status).sort_by(&:file_name)
  index = 1
  debates = []
  files.each do |file|
    puts 'parsing: data/' + file.file_name
    file_path = data_path + file.file_name
    url = file.parliament_url
    parser = HansardParser.new(file_path, url)
    debate = parser.parse(index)

    if debate.is_a?(Array)
      debate_array = debate
      debate_array.each {|d| d.valid?}
      index = debate_array.last.oral_answers.last.debate_index
      index = index.next
      debate_array.each {|d| debates << d }
    else
      debate.valid?
      index = debate.oral_answers.last.debate_index if debate.is_a?(OralAnswers)
      index = debate.sub_debates.last.debate_index if debate.is_a?(ParentDebate)

      index = index.next
      debates << debate
    end
    sleep sleep_seconds if sleep_seconds
  end


  debates.each_with_index do |debate, index|
    puts 'saving: ' + debate.name
    begin
      debate.save!
    rescue Exception => e
      debates.each_with_index do |a_debate, a_index|
        if a_index < index
          a_debate.destroy
        end
      end
      raise e
    end
  end

  files.each do |file|
    file.persisted = true
    file.save!
  end

  puts 'persisted: ' + date.to_s
end
