class Debate < ActiveRecord::Base

  has_many :contributions, :foreign_key => 'spoken_in_id', :dependent => :destroy, :order => 'id'
  has_many :debate_topics, :foreign_key => 'debate_id', :dependent => :destroy

  after_save :expire_cached_pages

  # before_create :create_slug
  # acts_as_slugged

  def create_slug
    self.slug = make_slug(name) do |candidate_slug|
      duplicate_found = Debate.find_by_date_and_publication_status
      duplicate_found
    end
  end

  def self.recent
    debates = find(:all,
        :order => "debates.`date` DESC",
        :limit => 20)
    debates = find_by_sql("select * from debates where type != 'BillDebate' and type != 'OralAnswer' and type != 'SubDebate' and type != 'OralAnswers' order by date DESC limit 20")
    debates = Debate::remove_duplicates debates
    debates.sort! {|a,b| (a.name <=> b.name) == 0 ? (a.date <=> b.date) : (a.name <=> b.name) }
    debates.in_groups_by {|d| d.name}
  end

  def Debate::find_referred_oral_answer debate
    find_by_date_and_oral_answer_no(debate.date, debate.re_oral_answer_no)
  end

  # def Debate::find_by_about_name about_type, url
    # # Debate.with_scope(:find => {:conditions => "about_type = '"+type+"'"}) do
      # # Debate.find :all,
          # # :conditions => ["o.url = ?", name],
          # # :joins => "AS d INNER JOIN "+type.downcase+"s AS o ON d.about_id = o.id"
    # # end
    # about = about_type.find_by_url url
    # Debate.find_by_about about_type.name, about.id, nil, nil, nil, nil
  # end

  def Debate::find_by_about_on_date about_type, url, date
    about = about_type.find_by_url url
    type = about_type.name
    id = about.id
    @debates = Debate.find_by_about(type, id, date.year, date.month, date.day, nil)
  end

  def Debate::find_by_about about_type, about_id, year, month, day, index
    month = Debate.mmm_to_mm month if month
    date = year+'-'+month+'-'+day if day

    if index
      index_prefix = index[0..0]
      type = 'OralAnswer' if index_prefix == 'o'
      type = 'SubDebate' if index_prefix == 'd'
      debates = find_all_by_date_and_about_id_and_about_type_and_about_index_and_type(date, about_id, about_type, index[1..2], type)
    elsif day
      debates = find_all_by_date_and_about_id_and_about_type(date, about_id, about_type)
    elsif month
      debates = find(:all,
         :conditions => ['year(date) = ? and month(date) = ? and about_id = ? and about_type = ?',
         year, month, about_id, about_type])
    elsif year
      debates = find(:all,
          :conditions => ['year(date) = ? and about_id = ? and about_type = ?',
          year, about_id, about_type])
    else
      debates = find_all_by_about_id_and_about_type(about_id, about_type)
    end

    debates
  end

  def Debate::find_by_index(year, month, day, index)
    month = Debate.mmm_to_mm month if month
    if index
      date = year+'-'+month+'-'+day
      debates = find_all_by_date_and_debate_index(date, index.to_i)

      debate = Debate::remove_duplicates(debates, false)[0]

      raise ActiveRecord::RecordNotFound.new('ActiveRecord::RecordNotFound: date ' + date + ' index ' + index.to_i.to_s + '   ' + debates.to_s) unless debate
      debate
    elsif day
      find_all_by_date(year+'-'+month+'-'+day, :order => "id")
    elsif month
        find(:all,
          :conditions => ['year(date) = ? and month(date) = ?', year, month],
          :order => "id")
    else
        find(:all,
          :conditions => ['year(date) = ?', year],
          :order => "id")
    end
  end

  ##
  # Finds debates by date, ordered by ascending date
  #
  def Debate::find_by_date(year, month, day)
    Debate.find_by_index(year, month, day, nil)
  end

  def Debate::match name
    find(:all,
      :conditions => "name like '%#{name}%'",
      :order => "date DESC")
  end

  def Debate::get_by_type type, debates
    debates.select {|d| d.publication_status == type}.group_by {|d| d.date}.to_hash
  end

  def Debate::remove_duplicates debates, exclude_bill_parents=true
    uncorrected = Debate::get_by_type 'U', debates
    advance = Debate::get_by_type 'A', debates
    final = Debate::get_by_type 'F', debates
    Debate::remove_duplicates_using uncorrected, advance, final, exclude_bill_parents
  end

  def Debate::remove_duplicates_using uncorrected, advance, final, exclude_bill_parents=true
    # puts uncorrected.size.to_s + ' ' + advance.size.to_s + ' ' + final.size.to_s
    final = final.to_hash if final.is_a?(ActiveSupport::OrderedHash)
    advance = advance.to_hash if advance.is_a?(ActiveSupport::OrderedHash)
    uncorrected = uncorrected.to_hash if uncorrected.is_a?(ActiveSupport::OrderedHash)

    final.each_key do |date|
      advance.delete date
      uncorrected.delete date
    end

    # puts uncorrected.size.to_s + ' ' + advance.size.to_s + ' ' + final.size.to_s
    advance.each_key do |date|
      uncorrected.delete date
    end

    # puts uncorrected.size.to_s + ' ' + advance.size.to_s + ' ' + final.size.to_s
    debates = (uncorrected.values << advance.values << final.values).flatten.sort {|a,b| b.date <=> a.date}

    if exclude_bill_parents
      bill_debates = debates.select {|d| d.is_a? BillDebate and d.sub_debates.size > 0}
      debates = debates.delete_if {|d| bill_debates.include? d }
    end
    debates
  end

  def is_uncorrected?
    publication_status == 'U'
  end

  def is_advance?
    publication_status == 'A'
  end

  def is_final?
    publication_status == 'F'
  end

  def short_name
    if name.size < 35
      name
    else
      name[0..35]+'...'
    end
  end

  def year
    date.year.to_s
  end

  def month
    Debate.mm_to_mmm date.month
  end

  def day
    Debate.to_num_str date.day
  end

  def index
    Debate.to_num_str debate_index
  end

  def date_hash
    {:year => year, :month => month, :day => day}
  end

  def calendar_hash
    {:year => date.year, :month => date.month, :day => date.day}
  end

  def id_hash
    date_hash.merge({:index => index})
  end

  def next_debate_id_hash
    begin
      debate = Debate.find_by_index year, month, day, next_index
      if debate
        if debate.is_a? BillDebate
          if debate.sub_debates.size > 0
            debate.sub_debates[0].id_hash
          else
            debate.id_hash
          end
        elsif debate.is_a? OralAnswers
          debate.sub_debates[0].id_hash
        else
          debate.id_hash
        end
      else
        nil
      end
    rescue
      nil
    end
  end

  def prev_debate_id_hash
    hash = nil
    if index != '01' and not(is_a? SubDebate and parent.is_a? BillDebate and index == '02')
      prev_index = Debate.to_num_str index.to_i-1
      begin
        debate = Debate.find_by_index year, month, day, prev_index
      rescue Exception => e
        debate = nil
      end

      if debate
        if debate.is_a? BillDebate
          hash = debate.prev_debate_id_hash
        elsif debate.is_a? OralAnswers
          hash = debate.prev_debate_id_hash
        elsif debate.is_a? OralAnswer
          hash = debate.id_hash
        elsif debate.is_a? SubDebate
          parent = debate.debate
          if parent.is_a? BillDebate
            hash = debate.id_hash
          elsif parent.sub_debates.size == 1
            hash = parent.id_hash
          else
            hash = debate.id_hash
          end
        else
          hash = debate.id_hash
        end
      end
    end
    hash
  end

  def contribution_id contribution
    anchor = nil

    if contributions and contributions.include? contribution
      anchor = (contributions.index(contribution) + 1).to_s
    elsif sub_debates and sub_debates.size > 0
      index = 1
      sub_debates.each do |sub_debate|
        anchor = sub_debate.contribution_index(contribution)
        if anchor
          anchor = (anchor+1).to_s
          # anchor = index.to_s + '.' + (anchor+1).to_s
          break
        else
          index = index.next
        end
      end
    end

    anchor
  end

  def date_to_s
    date_str = date.strftime "%d %b %Y"
    date_str = date_str[1, date_str.length - 1] if date_str.index('0') == 0
    date_str
  end

  def title_name s=':'
    name
  end

  def title separator=':'
    %Q[#{title_name}#{separator} #{date_to_s}#{separator} NZ Parliament]
  end

  def Debate::to_num_str num
    str = num.to_s
    str = '0'+str if num < 10
    str
  end

  MONTHS_LC = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']

  def Debate::mm_to_mmm mm
    MONTHS_LC[mm.to_i - 1]
  end

  def Debate::mmm_to_mm mmm
    mm = (MONTHS_LC.index(mmm) + 1).to_s
  end

  def Debate::to_date_hash date
    { :year => date.year.to_s,
      :month => Debate.mm_to_mmm(date.month),
      :day => Debate.to_num_str(date.mday) }
  end

  # def Debate::count_by_about about_type, about_id, publication_status
    # debate_count = Debate.count_by_sql "select count(*) from debates where about_type = '#{about_type}' and about_id = #{about_id} and publication_status = '#{publication_status}' and (debate_id is not null or type = 'DebateAlone')"
    # if about_type == 'Bill'
      # debate_count += DebateTopic.find_all_by_topic_type_and_topic_id(about_type, about_id).select {|t| t.debate.publication_status == publication_status }.size
    # end
    # debate_count
  # end

  # def Debate::debate_count cache, about_type, about_id
    # key = about_type + about_id.to_s
    # unless cache.has_key? key
      # uncorrected = Debate.count_by_about about_type, about_id, 'U'
      # advance = Debate.count_by_about about_type, about_id, 'A'
      # final = Debate.count_by_about about_type, about_id, 'F'
#
      # if uncorrected > advance and uncorrected > final
        # cache[key] = uncorrected
      # elsif advance > final
        # cache[key] = advance
      # else
        # cache[key] = final
      # end
    # end
#
    # cache[key]
  # end

  def Debate::get_debates_by_name debates
    debates = Debate::remove_duplicates debates
    debates_by_name = debates.group_by {|d| d.name.split('—')[0].sub('Third Readings','Third Reading')}
    debates_by_name.values.each do |list|
      list.sort! do |a,b|
        comparison = b.date <=> a.date
        if comparison == 0
          comparison = b.id <=> a.id
        end
        comparison
      end
    end

    names = debates_by_name.keys.sort do |a,b|
      debate = debates_by_name[a]
      other_debate = debates_by_name[b]
      comparison = other_debate.first.date <=> debate.first.date
      if comparison == 0
        comparison = debate.first.id <=> other_debate.first.id
      end
      comparison
    end

    return debates_by_name, names
  end

  def votes
    contributions.select { |o| o.is_vote? }.collect { |o| o.vote }
  end

  def geonames
    geonames = []
    contributions.each do |c|
      geonames << c.geonames
    end
    geonames.flatten.uniq
  end

  CACHE_ROOT = RAILS_ROOT + '/tmp/cache/views/theyworkforyou.co.nz'

  protected

    def uncache path
      if File.exist?(path)
        puts 'deleting: ' + path.sub(Debate::CACHE_ROOT, '')
        File.delete(path)
      end
    end

    def expire_cached_pages
      return unless ActionController::Base.perform_caching

      self.contributions.each do |contribution|
        if (mp = contribution.mp)
          uncache "#{Debate::CACHE_ROOT}/mps/#{mp.id_name}.cache"
        end
      end

      hash = id_hash
      year = hash[:year]
      month = hash[:month]
      day = hash[:day]
      index = hash[:index]
      index_path = "#{year}/#{month}/#{day}/#{index}"

      path = nil
      if hash.has_key? :portfolio_url
        uncache cache+'/portfolios.cache'
        path = "#{cache}/portfolios/#{hash[:portfolio_url]}/#{index_path}.cache"
      elsif hash.has_key? :bill_url
        uncache cache+'/bills.cache'
        path = "#{cache}/bills/#{hash[:bill_url]}/#{index_path}.cache"
      elsif hash.has_key? :committee_url
        path = "#{cache}/committees/#{hash[:committee_url]}/#{index_path}.cache"
      else
        path = "#{cache}/debates/#{index_path}.cache"
      end

      uncache path
      uncache path.sub("/#{index}", '')
      uncache path.sub("/#{day}/#{index}", '')
      uncache path.sub("/#{month}/#{day}/#{index}", '')
      uncache path.sub("/#{index_path}", '')

      unless path.include?('debates')
        uncache cache + '/debates.cache'
      end

      unless debate_topics.blank?
        debate_topics.each do |debate_topic|
          if debate_topic.topic.is_a? Bill
            path = "#{cache}/bills/#{debate_topic.topic.url}.cache"
            uncache path
          end
        end
      end
      uncache cache + '/index.cache'
    end

end
