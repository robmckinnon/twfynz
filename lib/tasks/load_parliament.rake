require File.dirname(__FILE__) + '/../parliament_loader.rb'

namespace :kiwimp do

  task :add_49th_parliament => :environment do
    ParliamentLoader.add_49th_parliament
  end

  task :add_48th_parliament_parties => :environment do
    ParliamentLoader.add_48th_parliament_parties
  end
end
