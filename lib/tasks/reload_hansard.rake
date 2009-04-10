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

      downloader = HansardDownloader.new
      dates.each {|date| downloader.redownload_date(date) }
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
      downloader = HansardDownloader.new
      downloader.unload_date date, publication_status
    else
      puts 'you need to specify date and status, e.g. rake kiwimp:reload_hansard date=2007-06-14 status=F'
    end
  end

end
