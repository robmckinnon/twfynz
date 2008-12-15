require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'uri'

class MpsDownloader

  def self.download_nats
    doc = Hpricot open('http://www.national.org.nz/MPList.aspx')

    (doc/'div.mp/h3/a').each do |mp|
      name = mp.inner_text.squeeze(' ').strip
      bio_page = mp['href']
      id = bio_page.split('=')[1]
      if id
        name = name.sub('Hon ','').sub('Dr ','').sub('Mr ','').sub(' QSO','').sub(' ONZM','')
        person = Mp.from_name name, Date.today

        if person
          member = person.member
          unless member.image
            name = name.downcase.gsub(' ','_')
            save_to = "/var/www/twfynz/public/images/mps/2008/#{name}_lg.jpg"


            img_src = "/images/people/#{id}_Large.jpg"
            puts 'downloading: ' + img_src
            self.download_image save_to, "www.national.org.nz", img_src

            bio_page = "http://www.national.org.nz/MP.aspx?Id=#{id}"
            member.image = "2008/#{name}.jpg"
            puts 'setting member image: ' + member.image
            member.save!
            person.party_bio_url = bio_page
            puts 'setting person bio: ' + bio_page
            person.save!
          end
        else
          raise 'unknown: ' + name
        end
      end
    end; nil
  end

  def self.download_labs
    doc = Hpricot open('http://www.labour.org.nz/our_mps.html')

    (doc/'div.ourMPItem/div/a').each do |mp|
      name = mp['title']
      bio_page = mp['href']
      id = bio_page.split('/').last.split('.')[0]
      if id
        image = "http://www.labour.org.nz/assets/Files%20and%20Images/MP%20Images/#{id.gsub('_','-')}-mppage.jpg.bin"
        name = name.sub('Hon ','').sub('Dr ','').sub('Mr ','').sub(' QSO','').sub(' ONZM','').downcase.gsub(' ','_')
        save_to = "/Users/x/apps/kiwimp/twfynz_search/public/images/mps/2008/#{name}_lg.jpg"

        puts name + ' ' + bio_page + ' ' + image
      end
    end; nil
  end

  def self.download_image image_file, img_host, img_src, mp=nil
    unless File.exist?(image_file)
      resp = response img_host, img_src
      if resp.code == "200"
        File.open(image_file, 'w') do |f|
          f.write resp.body
          if mp
            mp.alt_image = mp.img unless mp.alt_image
            mp.image = image_path.split('/').last + '/' + img_name
            mp.save!
          end
        end
      end
      puts img_src
    end
  end

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

        # self.download_image image_file, "www.parliament.nz", img_src
      end
    end
  end

  def self.download
    doc = Hpricot open('http://www.parliament.nz/en-NZ/MPP/MPs/MPs/Default.htm?pf=&sf=&lgc=1')

    (doc.at('table.listing').at('tbody') / 'a').each do |link|
      name = link.inner_text
      names = name.split(',')
      last = names[0].strip
      first = names[1].strip
      name = first + ' ' + last

      person = Mp.from_name name, Date.today
      party_name, electorate = link.at('..').next_sibling.inner_text.split(',')
      party_name.sub!(' Party','') unless party_name.include?('Maori')
      party_name.strip!
      electorate.strip!

      party = Party.from_vote_name party_name

      if party
        unless person
          person = Mp.new({:alt_last => last,
            :electorate => electorate,
            :last => last,
            :first => first,
            :img => '',
            :parliament_url => 'http://www.parliament.nz/' + link.attributes['href'],
            :wikipedia_url => "http://en.wikipedia.org/wiki/#{first}_#{last}",
            :former => "0",
            :elected => "2008",
            :member_of_id => party.id,
            :id_name => first.downcase+'_'+last.downcase})
          puts 'saving person: ' + person.full_name
          person.save!
        end

        member = Member.find_by_parliament_id_and_person_id(49, person.id)

        unless member
          member = Member.new({:from_what => 'General Election 2008',
            :electorate => electorate,
            :parliament_id => 49,
            :from_date => "2008-11-08",
            :party_id => party.id,
            :person_id => person.id})
          puts 'saving member: ' + person.full_name + ' ' + party.short + ' ' + electorate
          member.save!
        end
      else
        raise 'no Party found : ' + link.inner_text + ' ' + party_name + ' ' + electorate
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
