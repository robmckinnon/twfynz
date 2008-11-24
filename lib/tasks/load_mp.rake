namespace :kiwimp do

  task :download_nats => :environment do
    require File.dirname(__FILE__) + '/../mps_downloader.rb'
    MpsDownloader.download_nats
  end

  desc 'download mp page urls from parliament.nz'
  task :download_mps => :environment do
    require File.dirname(__FILE__) + '/../mps_downloader.rb'
    MpsDownloader.download
  end

  desc 'download mp images from parliament.nz'
  task :download_mp_images => :environment do
    image_path = RAILS_ROOT + '/public/images/mps/2007'
    Dir.mkdir image_path unless File.exist?(image_path)
    MpsDownloader.download_images image_path
  end

end
