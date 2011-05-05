namespace :kiwimp do

  desc 'downloads new www.legislation.govt.nz events via RSS'
  task :get_nzl_events => :environment do
    url = 'http://legislation.govt.nz/subscribe/nzpco-rss.xml'
    puts 'downloading: ' + url
    doc = Hpricot.XML open(url)
    count = 0

    (doc/'entry').each do |item|
      count += 1
      print '.' and $stdout.flush if count % 10 == 0

      NzlEvent.create_from :title => item.at('title/text()').to_s,
          :link => item.at('link')['href'].to_s,
          :description => item.at('content/text()').to_s,
          :pub_date => item.at('updated/text()').to_s
      # NzlEvent.create_from :title => item.at('title/text()').to_s,
          # :link => item.at('link/text()').to_s,
          # :description => item.at('description/text()').to_s,
          # :pub_date => item.at('pubDate/text()').to_s
    end
    puts ''
  end
end
