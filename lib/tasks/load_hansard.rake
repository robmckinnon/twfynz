namespace :kiwimp do

  desc 'download hansard from parliament.nz'
  task :download_hansard => :environment do
    require File.dirname(__FILE__) + '/../hansard_downloader.rb'
    HansardDownloader.new.download(uncorrected=true, update_of_persisted_files_table=false)
    HansardDownloader.new.download(uncorrected=false, update_of_persisted_files_table=false)
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
  task :load_hansard => [:load_questions] do
    # require File.dirname(__FILE__) + '/../hansard_parser.rb'
    sleep_seconds = ENV['sleep'].to_i if ENV['sleep']
    persist 'A', sleep_seconds
    persist 'F', sleep_seconds
  end

  task :git_pull_data do
    PersistedFile.git_pull
  end

  # desc 'load questions from /data'
  task :load_questions => [:environment, :git_pull_data] do
    require File.dirname(__FILE__) + '/../hansard_parser.rb'
    data_path = RAILS_ROOT + '/data/'
    dates = PersistedFile.unpersisted_dates 'U'

    dates.each do |date|
      files = PersistedFile.unpersisted_files(date, 'U').sort_by(&:file_name)
      oral_answers = nil

      files.each_with_index do |file, index|
        puts 'parsing: ' + file.storage_name
        parser = HansardParser.new(file.storage_name, file.parliament_url, file.debate_date)
        oral_answers = parser.parse_oral_answer(index+1, oral_answers)
      end

      puts 'saving: ' + oral_answers.class.name
      oral_answers.save!
      files.each do |f|
        f.persisted = true
        f.save!
      end
      puts 'persisted: ' + date.to_s

      oral_answers.create_url_slugs!
      puts 'created url slugs: ' + date.to_s
      Debate.expire_cached_pages date
    end
  end
end

def persist publication_status, sleep_seconds
  dates = PersistedFile.unpersisted_dates(publication_status).select {|d| date_after_sept_2005? d}

  dates.each { |date| persist_date date, publication_status, sleep_seconds }
end

def date_after_sept_2005? date
  date.year > 2005 || (date.year == 2005 && date.month > 9)
end

def persist_date date, publication_status, sleep_seconds=nil
  files = PersistedFile.unpersisted_files(date, publication_status).sort_by(&:file_name)
  index = 1
  debates = []
  files.each do |file|
    puts 'parsing: ' + file.storage_name
    parser = HansardParser.new(file.storage_name, file.parliament_url, file.debate_date)
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

  Debate.find_all_by_date_and_publication_status(date,publication_status).sort_by(&:debate_index).each do |debate|
    debate.create_url_slug
    debate.save!
  end
  SubDebate.find_all_by_url_slug(nil).each {|s| s.create_url_slug; s.save!}

  puts 'created url slugs: ' + date.to_s
  Debate.expire_cached_pages date
end
