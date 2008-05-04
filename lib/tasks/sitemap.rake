namespace :kiwimp do

  desc 'make sitemap file'
  task :make_sitemap => :environment do
    route_helper = RouteHelper.new nil,nil
    puts route_helper.get_url Debate.find(:all).first

    sitemap = []
    sitemap << '<?xml version="1.0" encoding="UTF-8"?>'
    sitemap << '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

    debates = Debate::remove_duplicates Debate.find(:all)

    debates.inject(sitemap) do |sitemap, debate|
      file = PersistedFile.find_by_parliament_url_and_publication_status(debate.source_url, debate.publication_status)
      sitemap << '  <url>'
      sitemap << '    <loc>' + route_helper.get_url(debate) + '</loc>'
      sitemap << '    <lastmod>' + file.download_date.to_s + '</lastmod>'
      sitemap << '  </url>'
      sitemap
    end

    sitemap << '</urlset>'
    puts sitemap.join("\n")
  end

end
