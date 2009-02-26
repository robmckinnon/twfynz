namespace :kiwimp do

  task :update_organisation_mentions do
    Organisation.find(:all).each {|o| o.save!}
  end

  desc ':load_hansard, :update_sitting_days, :update_organisation_mentions, :make_sitemap'
  task :all_update => [:environment, :load_hansard, :update_sitting_days, :update_organisation_mentions, :make_sitemap] do
  end

  desc 'sync hansard on local machine'
  task :sync_hansard => :environment do
    PersistedFile.git_pull
    PersistedFile.load_yaml_index
  end
  
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
        f.persisted_date = nil
        f.save!
      end
    end
    if count > 0
      puts 'changed ' + count.to_s + ' records in persisted_files to not persisted'
    else
      puts 'no records in persisted_files required changing'
    end
  end

  desc 'load debates and questions'
  task :load_hansard => [:load_questions] do
    sleep_seconds = ENV['sleep'].to_i if ENV['sleep']
    PersistedFile.load_debates 'A', sleep_seconds
    PersistedFile.load_debates 'F', sleep_seconds
  end

  task :git_pull_data do
    PersistedFile.git_pull
  end

  desc 'load questions'
  task :load_questions => [:environment, :git_pull_data] do
    PersistedFile.load_questions
  end
end
