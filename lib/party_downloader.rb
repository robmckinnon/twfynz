require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'uri'

module PartyDownloader

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

  def self.add_new_parties
    doc = Hpricot open('http://www.elections.org.nz/record/registers/registered-political-parties.html')

    new_parties = (doc/'td').in_groups_of(3).collect do |g|
      party = PartyProxy.new
      party.registered_name = g[1].to_plain_text.split('[').first.strip
      party.logo = (img = g[0].at('img')) ? img[:src].sub('../..','') : ''
      party.url = g[1].at('a') ? g[1].at('a')[:href] : ''
      party.abbreviation = g[2].to_plain_text.sub('?','').strip

      unless party.logo.blank?
        logo_name = party.registered_name.sub(' logo','').sub("M\xC4\x81ori","Maori").sub("Jim Anderton's ",'').sub('The ','').sub('RAM - ','').downcase.gsub(' ','_').sub('new_zealand','nz').sub(',_the_green_party_of_aotearoa/nz','')
        ext = File.extname(party.logo).downcase
        party.logo_file = logo_name+ext
      end

      party
    end; nil

    parties = Party.all

    new_parties.each do |data|
      party = parties.find {|p| p.name.downcase == data.registered_name.downcase}

      unless party
        party = Party.new
        party.name = data.registered_name
      end

      if party.short.blank?
        party.short = data.abbreviation.blank? ? party.name.sub('The ','').sub(' of New Zealand','') : data.abbreviation
      end

      party.short = party.short.sub('ALCP','Aotearoa Legalise Cannabis').sub('N W O','New World Order').sub('New Zealand','NZ').sub('RAM - Residents Action Movement','Residents Action Movement').sub('B&B','Bill and Ben Party').sub('RONZP','Republic of NZ Party')

      party.abbreviation = data.abbreviation unless data.abbreviation.blank?
      party.url = data.url unless data.url.blank?

      if data.logo_file
        party.logo = data.logo_file
        logo_path = RAILS_ROOT + '/public/images/parties/' + party.logo
        unless File.exists?(logo_path)
          puts 'opening ' + data.logo
          resp = response 'www.elections.org.nz', data.logo
          if resp.code == "200"
            File.open(logo_path, 'w') do |f|
              f.write resp.body
            end
            puts 'written ' + logo_path
          end
        end
      end

      puts 'saving ' + party.name
      puts 'short name ' + party.short
      party.save
    end; nil

  end

end

require 'morph'

class PartyProxy
  include Morph
end
