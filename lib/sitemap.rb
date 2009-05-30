require 'zlib'

class SiteMapIndex
  def write_to_file!
    site_map_types = [GeneralSiteMap, PortfoliosSiteMap, BillsSiteMap, MpsSiteMap, PartiesSiteMap, OrganisationsSiteMap]

    site_maps = site_map_types.inject([]) do |maps, site_map_type|
      site_map = site_map_type.new
      site_map.write_to_file!
      maps << site_map.entry
    end

    Debate.each_year_of_debates do |year, debates|
      site_map = DebatesSiteMap.new(year, debates)
      site_map.write_to_file!
      site_maps << site_map.entry
    end

    siteindex = [] <<
        %Q|<?xml version="1.0" encoding="UTF-8"?>\n| <<
        %Q|<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n|

    site_maps.each do |site_map|
      siteindex <<
          "<sitemap>" <<
          "<loc>#{site_map.location}</loc>" <<
          "<lastmod>#{site_map.last_modification}</lastmod>" <<
          "</sitemap>\n"
    end

    siteindex <<
        %Q|</sitemapindex>\n|

    File.open("#{RAILS_ROOT}/public/sitemap_index.xml",'w') do |file|
      puts 'writing: ' + file.path
      file.write siteindex.join('')
    end
  end
end


class SiteMapEntry
  attr_accessor :location, :last_modification

  def initialize location, last_modification
    location = "http://theyworkforyou.co.nz/#{location}" unless location.starts_with?('http')
    @location, @last_modification = location, last_modification
  end
end


class SiteMap
  attr_reader :most_recent_modification, :location

  @@route_helper = RouteHelper.new nil, nil

  def SiteMap::route_helper
    @@route_helper
  end

  def entry
    new_entry location.sub('public/',''), most_recent_modification
  end

  def new_entry location, last_modification=Date.today
    SiteMapEntry.new location, last_modification
  end

  def write_to_file!
    raise "can only write to file once" unless @site_map

    Zlib::GzipWriter.open("#{RAILS_ROOT}/#{@location}") do |file|
      puts 'writing: ' + @location
      file.write @site_map
    end
    @site_map = nil
  end

  protected
    def populate_sitemap name, pages
      site_map = [] <<
          %Q|<?xml version="1.0" encoding="UTF-8"?>\n| <<
          %Q|<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n|
      pages.each do |page|
        site_map <<
            "<url>" <<
            '<loc>' << page.location << "</loc>" <<
            '<lastmod>' << page.last_modification.to_s << "</lastmod>" <<
            "</url>\n" if page.location
      end
      site_map <<
          %Q|</urlset>\n|

      @most_recent_modification = pages.collect(&:last_modification).max
      @site_map = site_map.join('')
      @location = "public/sitemap_#{name}.xml.gz"
    end

    def populate_sitemap_for_model model_class, &block
      type = model_class.name.downcase
      url_helper_method = "url_for_#{type}".to_sym

      pages = [new_entry(type.pluralize)]

      pages = model_class.find(:all).inject(pages) do |pages, resource|
        location = SiteMap::route_helper.send(url_helper_method, resource)
        yield pages, resource, location if block_given?
        pages << new_entry(location) if location
        pages
      end

      populate_sitemap type.pluralize, pages
    end
end

class DebatesSiteMap < SiteMap

  def initialize year, debates
    pages = debates.inject([]) do |pages, debate|
      begin
        unless debate.is_parent_with_one_sub_debate? || debate.is_a?(OralAnswers)
          location = SiteMap::route_helper.get_url(debate)
          pages << new_entry(location, debate.download_date)
        end
      rescue Exception => e
        # puts "debate id #{debate.id}: " + e.message
      end
      pages
    end
    populate_sitemap year, pages
  end
end

class GeneralSiteMap < SiteMap
  def initialize
    pages = []
    pages << new_entry('')
    pages << new_entry('debates')
    pages << new_entry('about')

    Debate::CATEGORIES.each do |category|
      last_modification = Debate.remove_duplicates(Debate.find_all_by_url_category(category)).collect(&:download_date).max
      pages << new_entry(category, last_modification)
    end

    populate_sitemap 'general', pages
  end
end

class PortfoliosSiteMap < SiteMap
  def initialize
    populate_sitemap_for_model Portfolio
  end
end

class BillsSiteMap < SiteMap
  def initialize
    populate_sitemap_for_model(Bill) do |pages, bill, location|
      pages << new_entry("#{location}/submissions") unless bill.submissions.empty?
    end
  end
end

class MpsSiteMap < SiteMap
  def initialize
    populate_sitemap_for_model Mp
  end
end

class PartiesSiteMap < SiteMap
  def initialize
    populate_sitemap_for_model Party
  end
end

class OrganisationsSiteMap < SiteMap
  def initialize
    populate_sitemap_for_model(Organisation) do |pages, organisation, location|
      pages << new_entry("#{location}/mentions") if organisation.count_of_mentions > 0
    end
  end
end
