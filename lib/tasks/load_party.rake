require File.dirname(__FILE__) + '/../party_downloader.rb'

namespace :kiwimp do

  desc 'add new parties'
  task :add_new_parties => :environment do
    PartyDownloader.add_new_parties
  end
end
