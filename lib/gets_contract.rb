require 'morph'

class GetsContract
  include Morph

  def self.corrections
    corrections = []
    corrections << [' & ', ' and ']
    corrections << ['Deaprtment', 'Department']
    corrections << ['Dep of', 'Department of']
    corrections << ['Department Of', 'Department of']
    corrections << ['Dept of', 'Department of']
    corrections << [ /^NZ Defence$/, 'New Zealand Defence Force']
    corrections << [ /^NZDF/ ,  'New Zealand Defence Force']
    corrections << [ / NZ / , ' New Zealand ']
    corrections << [ /^NZ / , 'New Zealand ']
    corrections << ['MINISTRY OF EDUCATION', 'Ministry of Education']
    corrections << ['MInistry', 'Ministry']
    corrections << ['Mid Central', 'MidCentral']
    corrections << ['Minsitry', 'Ministry']
    corrections << ['Minstry', 'Ministry']
    corrections << ['Mimistry', 'Ministry']
    corrections << ['Mininistry', 'Ministry']
    corrections << ['Ministry Of', 'Ministry of']
    corrections << ['\xE2\x80\x93', '-']
    corrections << ['Ministry of Research Science', 'Ministry of Research, Science']
    corrections << ['Ministry of education', 'Ministry of Education']
    corrections << ['The Ministry of', 'Ministry of']
    corrections << ['Parliamentary Services', 'Parliamentary Service']
    corrections << ['Paliamentary Services', 'Parliamentary Service']
    corrections << [ /^MED$/, 'Ministry of Economic Development']
    corrections << [ /^National Library$/, 'National Library of New Zealand']
    corrections << [ /^ACC$/, 'Accident Compensation Corporation']
    corrections << [ /^Accident Compensation Corp$/, 'Accident Compensation Corporation']
    corrections << ['Auckland DHB', 'Auckland District Health Board']
    corrections << ['of Child Youth', 'of Child, Youth']
    corrections << [ /^Department of Child, Youth and Family$/, 'Department of Child, Youth and Family Services']
    corrections << ['Wgtn', 'Wellington']
    corrections << ['GSB Supplycorp Ltd', 'GSB Supplycorp']
    corrections << [ /^Inland Revenue$/, 'Inland Revenue Department']
    corrections << ['Inland Revenue -', 'Inland Revenue Department -']
    corrections << ['Inland Revenue,', 'Inland Revenue Department']
    corrections << ['Ministry of Social Development (MSD)', 'Ministry of Social Development']
    corrections << ['Land Information New Zealand (LINZ)', 'Land Information New Zealand']
    corrections << ['Ministry of Agriculture and Forestry (NZ)', 'Ministry of Agriculture and Forestry']
    corrections << ['Civil defence', 'Civil Defence']
    corrections << ['Ministry of Defence (NZ)', 'Ministry of Defence']
    corrections << ['regional', 'Regional']
    corrections << [ /^Ministry of Maori Development$/, 'Ministry of Maori Development (Te Puni Kokiri)']
    corrections << [ /^Statistics$/, 'Statistics New Zealand']
    corrections << ['The Tertiary Education Commission', 'Tertiary Education Commission']
    corrections << ['Tertiary Education Commission (TEC)', 'Tertiary Education Commission']
    corrections << ['Ministry of Womens Affairs', "Ministry of Women's Affairs"]
    corrections << [ /^NZAID$/, 'New Zealand Agency for International Development (NZAID)']
    corrections << ['New Zealend', 'New Zealand']
    corrections << ['Royal New Zealand Airforce', 'Royal New Zealand Air Force']
    corrections << ['State Service Commision', 'State Services Commision']
    corrections << ['Statistics NZ', 'Statistics New Zealand']
    corrections << [/^Te Puni Kokiri$/, 'Ministry of Maori Development (Te Puni Kokiri)']
    corrections << ['Statistics Department', 'Statistics New Zealand']
    corrections << ['Sport and Recreation New Zealand - SPARC', 'Sport and Recreation New Zealand']
    corrections << ['Commision', 'Commission']
    corrections << ['Inland Revenue Department, National Procurement Group', 'Inland Revenue Department - National Procurement Group']
    corrections << ['Eduction', 'Education']
    corrections << ['National Library of New Zealand Property and Services', 'National Library of New Zealand - Property and Services']
    corrections << [ /^New Zealand Fire$/, 'New Zealand Fire Service']
    corrections
  end

  def initialize id
    self.awarded_id = id
    self.url = "http://www.gets.govt.nz/Default.aspx?show=AwardedDetail&AwardedID=#{id}"
    doc = Hpricot open(self.url)

    (doc/'td.data').collect do |datum|
      label = datum.previous_sibling.inner_text
      label = label.gsub('$','').gsub('?',' ').gsub("\t",' ').gsub("\n",' ').gsub("\r",' ').strip.squeeze(' ')
      value = datum.inner_text.to_s.gsub("\r",'').squeeze(' ')

      self.morph(label, value)
    end

    if self.gets_ref
      self.gets_ref = self.gets_ref.to_i
      self.gets_ref = nil if self.gets_ref == 0
    end

    if self.department_email
      self.department_email = self.department_email.downcase
      if (domain = self.department_email[/\w+@(\w+\.[^ ]+)/,1])
        self.department_domain = domain
      end
    end

    if self.purchaser_organisation
      self.purchaser_name = self.purchaser_organisation
      self.purchaser_organisation = normalize(self.purchaser_name, self.class.corrections)
    end

    if self.contract_value_range
      self.contract_value_min, self.contract_value_max = values(self.contract_value_range, self.or_if_over_50_m)
    end
  end

  def values value_range, over_50m
    low = high = nil
    million = 1000000
    thousand = 1000
    unless (value_range.blank? || value_range == "Not Stated")
      magnitude_change = value_range.include?('$')
      range = String.new(value_range).sub('$',' ').squeeze(' ').sub(' - ',' to ').strip
      if range[/(.+) to (.+) M/]
        low = $1.to_f * (magnitude_change ? thousand : million)
        high = $2.to_f * million
      elsif range[/(.+) to (.+) K/]
        low = $1.to_f * (magnitude_change ? 1 : thousand)
        high = $2.to_f * thousand
      end
    end

    if !over_50m.blank? && !over_50m.downcase[/(n\/a|estimate|^-$|various)/]
      text = over_50m.gsub(',','').gsub('$','').downcase.strip
      if text[/(\d+) - (\d+)/]
        low = $1.to_i
        high = $2.to_i
      elsif text[/(\d+)k - (\d+)k/]
        low = $1.to_f * thousand
        high = $2.to_f * thousand
      elsif text[/depending on more than ([\d|\.]+)m/]
        low = $1.to_f * million
        high = $1.to_f * million
      elsif text[/^([\d|\.]+)\s?m$/]
        low = $1.to_f * million
        high = $1.to_f * million
      else
        puts 'cannot parse over_50m: ' + over_50m
      end
    end

    low ? [low.to_i, high.to_i] : [nil, nil]
  end

  def normalize text, corrections
    normalized = String.new text.squeeze(' ')
    corrections.each do |x|
      normalized.gsub!(x[0],x[1])
    end
    normalized.to_s.split(' - ').first.to_s.split(' (').first.to_s
  end
end
