require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'uri'

class MpsDownloader

  def self.download_images image_path
    mps = Mp.find(:all).select{|mp| !mp.parliament_url.blank?}
    mps.each do |mp|
      doc = Hpricot open(mp.parliament_url)

      puts mp.id_name
      img_src = doc.at('td.image').at('img')

      if img_src
        img_src = img_src.attributes['src']
        img_name = img_src.split('/').last
        image_file = image_path+'/'+img_name

        mp.alt_image = mp.img unless mp.alt_image
        mp.image = image_path.split('/').last + '/' + img_name.tr('0123456789','')
        mp.save!

        # unless File.exist?(image_file)
          # resp = response "www.parliament.nz", img_src
          # if resp.code == "200"
            # File.open(image_file, 'w') do |f|
              # f.write resp.body
              # mp.alt_image = mp.img unless mp.alt_image
              # mp.image = image_path.split('/').last + '/' + img_name
              # mp.save!
            # end
          # end
          # puts img_src
        # end
      end
    end
  end

  def self.download
    doc = Hpricot open('http://www.parliament.nz/en-NZ/MPP/MPs/MPs/Default.htm?pf=&sf=&lgc=1')

    (doc.at('table.listing').at('tbody')/'a').each do |link|
      name = link.inner_text
      names = name.split(',')
      last = names[0]
      first = names[1]
      name = first + ' ' + last

      mp = Mp.from_name name
      if mp
        puts mp.id_name
        mp.parliament_url = 'http://www.parliament.nz/' + link.attributes['href']
        mp.alt_last = mp.last unless mp.alt_last
        mp.last = last
        mp.save!
        puts mp.to_yaml
      else
        raise 'no MP found for: ' + link.inner_text
      end
    end
  end

  private

    def self.response host, path
      resp = nil
      Net::HTTP.start(host) do |http|
        resp = http.get(path,
            {
              "Host" => host,
              "User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; rv:1.7.3) Gecko/20040913 Firefox/0.10.1",
              "Accept" => "text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5",
              "Accept-Language" => 'en-us,en;q=0.7,en-gb;q=0.3',
              "Accept-Encoding" => 'gzip,deflate',
              "Accept-Charset" => 'ISO-8859-1,utf-8;q=0.7,*;q=0.7'
        })
      end
      resp
    end

end
