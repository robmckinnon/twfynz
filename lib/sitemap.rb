class SiteMapIndex
  def write_to_file!
    site_maps = [GeneralSiteMap, PortfoliosSiteMap, BillsSiteMap, MpsSiteMap, PartiesSiteMap, OrganisationsSiteMap].inject([]) do |maps, site_map_type|
      maps << site_map_type.new
    end
    site_maps += DebatesSiteMap::get_site_maps
    site_maps.each { |site_map| site_map.write_to_file! }

    siteindex = [] <<
        %Q|<?xml version="1.0" encoding="UTF-8"?>\n| <<
        %Q|<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n|

    site_maps.each do |site_map|
      siteindex <<
          "<sitemap>" <<
          "<loc>http://theyworkforyou.co.nz/#{site_map.location}</loc>" <<
          "<lastmod>#{site_map.most_recent_modification}</lastmod>" <<
          "</sitemap>\n"
    end

    siteindex <<
        %Q|</sitemapindex>\n|

    File.open("public/sitemap_index.xml",'w') do |file|
      file.write siteindex.join('')
    end
  end
end

Page = Struct.new(:location, :last_modification)

class SiteMap
  attr_reader :most_recent_modification, :location

  @@route_helper = RouteHelper.new nil, nil

  def SiteMap::route_helper
    @@route_helper
  end

  def write_to_file!
    File.open("public/#{@location}",'w') do |file|
      file.write @site_map
    end
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
      @location = name
    end

    def populate_sitemap_for_model model_class, &block
      type = model_class.name.downcase
      url_helper_method = "url_for_#{type}".to_sym

      pages = model_class.find(:all).inject([]) do |pages, resource|
        url = SiteMap::route_helper.send(url_helper_method,resource)
        last_modification = Date.today
        yield pages, resource, url, last_modification if block_given?
        pages << Page.new(url, last_modification)
      end
      pages << Page.new("http://theyworkforyou.co.nz/#{type.pluralize}", Date.today)
      populate_sitemap "sitemap_#{type.pluralize}.xml", pages
    end
end

class DebatesSiteMap < SiteMap

  def DebatesSiteMap::get_site_maps
    site_maps = []
    Debate.each_year_of_debates do |year, debates|
      site_maps << DebatesSiteMap.new(year, debates)
    end
    site_maps
  end

  def initialize year, debates
    pages = debates.inject([]) do |pages, debate|
      begin
        unless debate.is_parent_with_one_sub_debate? || debate.is_a?(OralAnswers)
          url = SiteMap::route_helper.get_url(debate)
          last_modification = debate.download_date
          pages << Page.new(url, last_modification)
        end
      rescue Exception => e
        # puts "debate id #{debate.id}: " + e.message
      end
      pages
    end
    populate_sitemap "sitemap_#{year}.xml", pages
  end
end

class GeneralSiteMap < SiteMap
  def initialize
    pages = []
    last_modification = Date.today
    pages << Page.new('http://theyworkforyou.co.nz/', last_modification)
    pages << Page.new('http://theyworkforyou.co.nz/debates', last_modification)
    pages << Page.new('http://theyworkforyou.co.nz/about', last_modification)

    Debate::CATEGORIES.each do |category|
      last_modification = Debate.remove_duplicates(Debate.find_all_by_url_category(category)).collect(&:download_date).max
      pages << Page.new("http://theyworkforyou.co.nz/#{category}", last_modification)
    end

    populate_sitemap "sitemap_general.xml", pages
  end
end

class PortfoliosSiteMap < SiteMap
  def initialize
    populate_sitemap_for_model Portfolio
  end
end

class BillsSiteMap < SiteMap
  def initialize
    populate_sitemap_for_model(Bill) do |pages, bill, url, last_modification|
      pages << Page.new("#{url}/submissions", last_modification) unless bill.submissions.empty?
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
    populate_sitemap_for_model(Organisation) do |pages, organisation, url, last_modification|
      pages << Page.new("#{url}/mentions", last_modification) if organisation.count_of_mentions > 0
    end
  end
end
