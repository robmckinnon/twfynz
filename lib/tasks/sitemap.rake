namespace :kiwimp do

  desc 'make sitemap file'
  task :make_sitemap => :environment do
    SiteMapIndex.new.write_to_file!
  end

end
