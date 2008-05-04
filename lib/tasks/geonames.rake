
namespace :geonames do

  task :find => :environment do
    contributions = Contribution.find_by_sql('select * from contributions limit 1,100')
    names         = Geoname.find_all_names
    contributions.each do |c|
      names.each do |n|
        geoname = Geoname.find_by_geonameid(n.geonameid)
        puts geoname.to_yaml
        puts n.feature_code + ' ' + n.name + ' ' + c.section.sitting.date.to_s if c.text.include?(n.name)
      end
    end
  end

  desc "Populate database from db/NZ.txt file"
  task :populate => :environment do

    File.new(File.dirname(__FILE__) + '/../../db/NZ.txt').each do |line|
      attributes = parse_line(line)
      geonameid = attributes[:geonameid]
      geoname = Geoname.find_by_geonameid(geonameid)

      if SUPPRESS_GEONAMEIDS.include? geonameid.to_i
          puts 'ignoring ' + attributes[:asciiname] + ' (' + geonameid + ')'

      elsif geoname
        if geoname.modification_date < attributes[:modification_date]
          puts 'updating ' + attributes[:asciiname] + ' (' + geonameid + ')'
          geoname.update_attributes(attributes)
        end
      elsif attributes[:feature_code].starts_with? 'PPL'
        puts 'creating ' + attributes[:asciiname] + ' (' + geonameid + ')'
        geoname = Geoname.create(attributes)
      end
    end
  end

  private

  def parse_line line
    d = line.split("\t")
    {:geonameid => d[0],
        :name => d[1],
        :first_word_in_name => d[1].split.first,
        :asciiname => d[2],
        :alternatenames => d[3],
        :latitude => d[4],
        :longitude => d[5],
        :feature_class => d[6],
        :feature_code => d[7],
        :country_code => d[8],
        :cc2 => d[9],
        :admin1_code => d[10],
        :admin2_code => d[11],
        :admin3_code => d[12],
        :admin4_code => d[13],
        :population => d[14],
        :elevation => d[15],
        :gtopo30 => d[16],
        :timezone => d[17],
        :modification_date => d[18]}
  end
end