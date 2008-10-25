require File.dirname(__FILE__) + '/../party_downloader.rb'

namespace :kiwimp do

  desc 'add new parties'
  task :add_new_parties => :environment do
    PartyDownloader.add_new_parties
  end

  task :set_wikipedia_url => :environment do
    PartyDownloader.set_wikipedia_url
  end
end
