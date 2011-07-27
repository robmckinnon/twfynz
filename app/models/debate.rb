require 'acts_as_slugged'

class Debate < ActiveRecord::Base

  has_many :contributions, :foreign_key => 'spoken_in_id', :dependent => :destroy, :order => 'id'
  has_many :debate_topics, :foreign_key => 'debate_id', :dependent => :destroy
  has_many :bill_events, :as => :source, :dependent => :destroy

  after_save :expire_cached_contributor_pages, :expire_cached_pages, :update_bill_events

  include ExpireCache

  acts_as_slugged

  CATEGORIES = %w[visitors motions urgent_debates_declined points_of_order
      tabling_of_documents obituaries speakers_rulings personal_explanations
      appointments urgent_debates privilege speakers_statements resignations
      ministerial_statements adjournment parliamentary_service_commission
      business_of_select_committees
      business_statement general_debate business_of_the_house sittings_of_the_house
      members_sworn address_in_reply debate_on_prime_ministers_statement list_member_vacancy
      budget_debate standing_orders maiden_statement valedictory_statement members_bills
      prime_ministers_statement debate_on_budget_policy_statement offices_of_parliament
      state_opening officers_of_parliament reinstatement_of_business commission_opening_of_parliament]

  MONTHS_LC = %w[jan feb mar apr may jun jul aug sep oct nov dec]

  WORD_JOIN = [
      ['Prime Minister', 'Prime~Minister'],
      ['New Zealand First Party', 'New~Zealand~First~Party'],
      ['New Zealand First', 'New~Zealand~First'],
      ['New Zealand', 'New~Zealand'],
      ['Madam Speaker', 'Madam~Speaker'],
      ['Labour Party', 'Labour~Party'],
      ['National Party', 'National~Party'],
      ['Māori Party', 'Māori~Party'],
      ['Green Party', 'Green~Party'],
      ['United Future', 'United~Future'],
      ['point of order', 'point~of~order'],
      ['question time', 'question~time'],
      ['seek leave to table', 'seek~leave~to~table'],
      ['Leave is sought to table', 'Leave~is~sought~to~table'],
      ['There is no objection', 'There~is~no~objection'],
      ['There is objection', 'There~is~objection'],
      ['Is there any objection','Is~there~any~objection'],
      ['court order','court~order'],
      ['legal services','legal~services'],
      ['management system','management~system'],
      ['free-trade agreement','free-trade~agreement'],
      ['Māori Trustee','Māori~Trustee'],
      ['Federation of Māori Authorities','Federation~of~Māori~Authorities'],
      ['New Zealand Māori Council','New~Zealand~Māori~Council'],
      ['Māori Council','Māori~Council'],
      ['Māori and Pasifika','Māori~and~Pasifika'],
      ['Māori or Pasifika','Māori~or~Pasifika'],
      ['Māori Land Court','Māori~Land~Court'],
      ['Māori Language Act','Māori~Language~Act'],
      ['Māori Deaf',' Māori~Deaf'],
      ['Māori Television','Māori~Television'],
      ['Māori King','Māori~King'],
      ['Treaty of Waitangi','Treaty~of~Waitangi'],
      ['supports this legislation','supports~this~legislation'],
      ['opposes this legislation','opposes~this~legislation'],
      ['waste minimisation','waste~minimisation'],
      ['climate change','climate~change'],
      ['John Key','John~Key'],
      ['Winston Peters','Winston~Peters'],
      ['Ministry of ','Ministry~of~'],
      ['Ministry for the ', 'Ministry~for~the~'],
      ['State-owned enterprises','State-owned~enterprises']
  ]

  COMMON_WORDS = %w[a able about absolutely ago actually after again against all
  already also always am an and another answer any anything are around as ask asked at
  back be because been before being believe best better between bit both but by
  came can cannot case certainly clear come confirm could course
  day did do does doing done down during end even every example
  fact first for forward from further
  get getting give given go going good got great
  had has have having he hear heard
  her here him his how i if important in including into is it its just
  know knows last leave led like little long look lot
  made make making many matter matters may me might more most much must my
  need never new next no not nothing now number of off on one only
  or other our out over own part particular particularly
  person people point provide put raise really received right question questions quite
  s said same say saying says see seen select set she should since
  so some something still such sure take taken tell than that
  the their them then there these they thing things think this those through time to
  today told too two under understand up us use used very
  want was way we well were went what when where whether which
  who why will with within work would year yes yet you your
  te ki ka e o ko ana atu mai ia kei kia]

  COMMON_WORDS_HASH = COMMON_WORDS.inject({}) {|hash, value| hash[value] = true; hash}

  WORDLE_IGNORE = ['House', 'Mr', 'Dr', /[^~]Government[^~]/, /[^~]Minister[^~]/,
    /\sbill[^a-z~]/, /[^~]Bill[^a-z~]/, /point~of~order/i, /[^a-z~]member[^~]/,
    /New~Zealand[^a-z~]/,
    'New~Zealand~First~Party',
    'New~Zealand~First',
    'Madam~Speaker',
    'Labour~Party',
    'Labour',
    'National~Party',
    'National',
    'Māori~Party',
    'Green~Party',
    'United~Future',
    'ACT',
    'New~Zealanders',
    'support','public','legislation']

  WORDLE_IGNORE_HASH = WORDLE_IGNORE.inject({}) {|hash, value| hash[value] = true; hash}

  class << self

    def wordlize text
      text.gsub(/[^A-Za-z0-9]/,' ').gsub(' ','~').squeeze('~').chomp('~').sub('M~ori','Māori')
    end

    def wordlize_list text, list
      list.each { |item| text.gsub!(item, wordlize(item))}
    end

    def wordle_text_for_date date
      date = Date.parse(date)
      debates = Debate.find_all_by_date(date, :include => :contributions)
      remove_duplicates(debates)
      text = debates.collect(&:wordle_text).join("\n")
      date = "#{date.day}~#{mm_to_mmm(date.month).capitalize}~#{date.year}"
      relative_frequency = 0.6
      wordlize_text text, date, relative_frequency
    end

    def wordlize_text text, addition=nil, relative_frequency=nil
      WORD_JOIN.each { |words,phrase| text.gsub!(words, phrase) }

      wordlize_list text, Committee.all_committee_names
      wordlize_list text, Minister.all_minister_titles
      wordlize_list text, (Portfolio.all_portfolio_names << 'Social Development' << 'Agriculture and Forestry')
      wordlize_list text, Bill.all_bill_names
      wordlize_list text, Mp.all_mp_names

      NzlEvent.all_act_names.each do |act|
        act_without_year = act[/([^\d]+)\s/,1]
        text.gsub!(act, wordlize(act_without_year))
        text.gsub!(act_without_year, wordlize(act_without_year))
      end

      WORDLE_IGNORE.each { |ignore| text.gsub!(ignore, ' ')}
      COMMON_WORDS.each do |common|
        text.gsub!(/\s#{common}[^a-z~]/i,' ')
      end

      text = text.split(' ').select {|word| !COMMON_WORDS_HASH[word.downcase] }.join(' ')
      text.gsub!('’s', '')
      text.gsub!(' ngā ',' ')
      text.gsub!(' nā ',' ')
      text.gsub!(' rā ',' ')
      top_frequency = top_word_frequency(text)

      text.gsub!(/\$([\d\.?]+)\s([m|b]illion)/, '$\1~\2')
      text.gsub!(/(\d+)\s((month|year|percent|week)s?)/, '\1~\2')
      text.gsub!(' and ',' ')
      additional_emphasis = Array.new(top_frequency*relative_frequency, addition).join(' ') if addition && relative_frequency
      site_emphasis = Array.new(frequency_for_site_name(top_frequency), 'data~from~TheyWorkForYou.co.nz').join(' ')
      "#{text.squeeze(' ')} #{additional_emphasis} #{site_emphasis}"
    end

    def top_word_frequency text
      words = text.to_latin.to_s.split(/[^a-zA-Z~]/)
      freqs = Hash.new(0)
      words.each do |word|
        downcase = word.downcase
        ignore = word.blank? || COMMON_WORDS_HASH[downcase] || WORDLE_IGNORE_HASH[downcase]
        freqs[word] += 1 unless ignore
      end
      freqs = freqs.sort_by {|x,y| y }.reverse
      (freqs[0][1] + freqs[1][1]) / 2
    end

    def frequency_for_site_name top_frequency
      (top_frequency * 0.5)
    end

    def recreate_url_slugs!
      find(:all).each {|d| d.url_slug = nil; d.url_category = nil; d.save!}

      find(:all).in_groups_by(&:date).each do |group|
        group.sort_by(&:debate_index).each do |debate|
          debate.create_url_slug
          debate.save!
        end
      end
    end

    def each_year_of_debates
      all_debates = remove_duplicates find(:all)
      year_to_debates = all_debates.group_by{ |d| d.date.year }
      descending_years = year_to_debates.keys.sort.reverse
      descending_years.each do |year|
        debates = year_to_debates[year]
        yield year, debates
      end
    end

    def find_by_url_category_and_url_slug date, category, url_slug
      if category == 'debates'
        debates = find_all_by_date_and_url_slug date.yyyy_mm_dd, url_slug
      else
        debates = find_all_by_date_and_url_category_and_url_slug date.yyyy_mm_dd, category, url_slug
      end
      remove_duplicates(debates).first
    end

    def recent
      debates = remove_duplicates find_by_sql("select * from debates where type != 'BillDebate' and type != 'OralAnswer' and type != 'SubDebate' and type != 'OralAnswers' order by date DESC limit 20")
      debates.sort! {|a,b| (comparison = a.name <=> b.name) == 0 ? (a.date <=> b.date) : comparison }
      debates.in_groups_by(&:name)
    end

    def find_latest_by_status publication_status
      d = PersistedFile.find_all_by_publication_status(publication_status).collect(&:debate_date).max
      if d
        latest_debates = find_by_date(d.year.to_s, mm_to_mmm(d.month.to_s), d.day.to_s)
        latest_debates.delete_if do |d|
          (publication_status == 'A' && d.kind_of?(SubDebate) ) ||
          (publication_status == 'U' && d.kind_of?(OralAnswers) )
        end
        latest_debates.delete_if {|d| d.publication_status != publication_status}
        latest_debates
      else
        []
      end
    end

    def find_referred_oral_answer debate
      find_by_date_and_oral_answer_no(debate.date, debate.re_oral_answer_no)
    end

    def find_by_about_on_date about_type, about_url, date
      about = about_type.find_by_url about_url
      type = about_type.name
      id = about.id
      @debates = Debate.find_by_about(type, id, date.year, date.month, date.day, nil)
    end

    def find_by_about_on_date_with_slug about_type, about_url, date, slug
      abouts = about_type.find_all_by_url(about_url)
      debate = find_by_about_with_slug(about_type, abouts.first.id, date, slug)
      debate = find_by_about_with_slug(about_type, abouts.last.id,  date, slug) unless debate
      debate
    end

    def find_by_about_with_slug about_type, about_id, date, slug
      debates = find_by_about(about_type.to_s, about_id, date.year, date.month, date.day, nil, slug)
      remove_duplicates(debates).first
    end

    def find_by_about_on_date_with_index about_type, about_url, date, index
      abouts = about_type.find_all_by_url(about_url)
      debate = find_by_about_with_index(about_type, abouts.first.id, date, index)
      debate = find_by_about_with_index(about_type, abouts.last.id,  date, index) unless debate
      debate
    end

    def find_by_about_with_index about_type, about_id, date, index
      debates = find_by_about(about_type.to_s, about_id, date.year, date.month, date.day, index)
      remove_duplicates(debates).first
    end

    def find_by_about about_type, about_id, year, month, day, index, slug=nil
      month = mmm_to_mm month if month
      date = year+'-'+month+'-'+day if day

      if index
        index_prefix = index[0..0]
        type = 'OralAnswer' if index_prefix == 'o'
        type = 'SubDebate' if index_prefix == 'd'
        debates = find_all_by_date_and_about_id_and_about_type_and_about_index_and_type(date, about_id, about_type, index[1..2], type)
      elsif slug
        debates = find_all_by_date_and_about_id_and_about_type_and_url_slug(date, about_id, about_type, slug)
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

    def find_with_url_category(category)
      remove_duplicates(find_all_by_url_category(category), false)
    end

    def find_by_date_and_index(date, index)
      debate = find_by_index(date.year, date.month, date.day, index)
      debate = debate.sub_debate if debate.is_parent_with_one_sub_debate?
      debate
    end

    def find_by_index year, month, day, index
      if index
        date = year+'-'+mmm_to_mm(month)+'-'+day
        debates = find_all_by_date_and_debate_index(date, index.to_i)
        debate = remove_duplicates(debates, false)[0]
        raise ActiveRecord::RecordNotFound.new('ActiveRecord::RecordNotFound: date ' + date + ' index ' + index.to_i.to_s + '   ' + debates.to_s) unless debate
        debate
      else
        find_by_date year, month, day
      end
    end

    def find_by_date year, month, day
      if day
        debates = find_all_by_date(year+'-'+mmm_to_mm(month)+'-'+day, :order => "id")
      elsif month
        debates = find(:all, :conditions => ['year(date) = ? and month(date) = ?', year, mmm_to_mm(month)], :order => "id")
      else
        debates = find(:all, :conditions => ['year(date) = ?', year], :order => "id")
      end
      remove_duplicates(debates, false)
    end

    def match name
      find(:all, :conditions => "name like '%#{name}%'", :order => "date DESC")
    end

    def get_by_type type, debates
      debates.select {|d| d.publication_status == type}.group_by {|d| d.date}.to_hash
    end

    def remove_duplicates debates, exclude_bill_parents=true
      uncorrected = get_by_type('U', debates)
      advance =     get_by_type('A', debates)
      final =       get_by_type('F', debates)
      remove_duplicates_using uncorrected, advance, final, exclude_bill_parents
    end

    def remove_duplicates_using uncorrected, advance, final, exclude_bill_parents=true
      final = final.to_hash if final.is_a?(ActiveSupport::OrderedHash)
      advance = advance.to_hash if advance.is_a?(ActiveSupport::OrderedHash)
      uncorrected = uncorrected.to_hash if uncorrected.is_a?(ActiveSupport::OrderedHash)

      final.each_key { |date| advance.delete date; uncorrected.delete date }
      advance.each_key { |date| uncorrected.delete date }
      debates = (uncorrected.values << advance.values << final.values).flatten.sort {|a,b| b.date <=> a.date}

      # puts uncorrected.size.to_s + ' ' + advance.size.to_s + ' ' + final.size.to_s

      debates = debates.delete_if {|d| d.is_a?(BillDebate) && d.sub_debates.size > 0 } if exclude_bill_parents
      debates
    end

    def to_num_str num
      (num < 10) ? "0#{num}" : num.to_s
    end

    def mm_to_mmm mm
      Debate::MONTHS_LC[mm.to_i - 1]
    end

    def mmm_to_mm mmm
      Debate::MONTHS_LC.index(mmm) ? (Debate::MONTHS_LC.index(mmm) + 1).to_s : mmm
    end

    def to_date_hash date
      { :year => date.year.to_s,
        :month => mm_to_mmm(date.month),
        :day => to_num_str(date.mday) }
    end

    def debates_in_groups_by_name debates
      debates = remove_duplicates debates
      in_groups_by_name = []
      debates.group_by(&:normalized_name).each {|name, list| in_groups_by_name << list}
      in_groups_by_name.each do |list|
        list.sort! do |a,b|
          comparison = b.date <=> a.date
          if comparison == 0
            comparison = b.id <=> a.id
          end
          comparison
        end
      end

      in_groups_by_name.sort! do |a, b|
        debate = a.last
        other_debate = b.last
        comparison = other_debate.date <=> debate.date
        if comparison == 0
          comparison = debate.id <=> other_debate.id
        end
        comparison
      end

      in_groups_by_name
    end

    # expires other pages in that month
    def expire_cached_pages date
      puts "finding all in month: #{date.year} #{date.month}"
      debates = Debate.find_by_date date.year, date.month, nil
      puts 'found: '+debates.size.to_s
      debates.each { |d| d.expire_cached_pages }
    end

    def create_debate_topics debates
      debates = debates.select { |debate| debate.debate_topics.blank? }
      contributions = debates.collect(&:motion_to_now_read_contributions).flatten

      debate_to_bill_names = {}
      contributions.each { |c| debate_to_bill_names[c.debate] = c.bill_names }

      debate_to_bill_names.each_pair { |d,b| puts d.id.to_s + " -> " + b.join(' | ') }
      puts "\n unknown bills:"
      debate_to_bill_names.each_pair do |d, bill_names|
        bill_names.select{|n| Bill.from_name_and_date(n, d.date).nil? }.each { |name| puts "#{d.date} #{name}" }
      end ;nil

      debate_to_bill_names.each do |debate, bill_names|
        bills = bill_names.collect { |name| Bill.from_name_and_date(name, debate.date) }.compact

        bills.each do |bill|
          topic = DebateTopic.find_or_create_by_debate_id_and_topic_id_and_topic_type(debate.id, bill.id, 'Bill')
          BillEvent.refresh_events_from_bill bill
          puts topic.inspect
        end
        nil
      end ; nil
    end
  end

  def motion_to_now_read_contributions
    contributions.select(&:is_motion_to_now_read?)
  end

  def formerly_about_bill
    bills = debate_topics.collect(&:formerly_part_of_bill).compact.uniq
    if bills && bills.size == 1
      bills.first
    else
      nil
    end
  end

  def wordle_text
    if contributions
      non_procedural = contributions.select{ |c| !c.is_a? Procedural }
      non_procedural.collect(&:wordle_text).join("\n\n")
    else
      ''
    end
  end

  def normalized_name
    name.split('—')[0].sub('Third Readings','Third Reading')
  end

  def is_parent_with_one_sub_debate?
    false
  end

  def make_category
  end

  def find_by_candidate_category
  end

  def create_url_slug
    populate_url_slug make_url_slug_text.gsub(' and ',' ')
    self.url_slug
  end

  def populate_url_slug slug_text
    self.url_slug = make_slug(slug_text) do |candidate_slug|
      non_numbered_slug = !candidate_slug[/_\d+$/]

      duplicate = find_by_candidate_slug candidate_slug
      if non_numbered_slug
        if duplicate
          duplicate.url_slug = "#{duplicate.url_slug}_1"
          duplicate.save!
        else
          duplicate = find_by_candidate_slug "#{candidate_slug}_1"
        end
      end
      duplicate
    end unless slug_text.blank? || self.url_slug

    self.url_slug = 'lange_luxton_falloon_donald' if self.url_slug == 'rt_hon_david_russell_lange_onz_ch_john'
  end

  def description
    if contributions.size > 0
      description = contributions.first.first_sentence
      index = 1
      while (!description || description.starts_with?('Debate resumed')) && index < contributions.size
        description = contributions[index].first_sentence
        index = index.next
      end
      description
    else
      ''
    end
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
    (name.size < 35) ? name : "#{name[0..35]}..."
  end

  def parent_name
    nil
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

  def download_date
    file = PersistedFile.find_by_parliament_url_and_publication_status(source_url, publication_status)
    file.download_date
  end

  def id_hash
    hash = {}.merge(date_hash)
    unless url_slug.blank?
      hash.merge!(:url_slug => url_slug)
      hash.merge!(:url_category => 'debates') if url_category.blank?
      hash.delete(:index)
    else
      hash.merge!(:url_slug => nil)
    end
    hash.merge!(:url_category => url_category) unless url_category.blank?
    hash.merge!({:index => index}) if (url_category.blank? && url_slug.blank?)
    hash
  end

  def next_debate
    begin
      @next_debate ||= Debate.find_by_index year, month, day, next_index
    rescue Exception => e
      nil
    end
  end

  def next_debate_id_hash
    if(debate = next_debate)
      case debate
        when BillDebate
          debate.sub_debates.empty? ? debate.id_hash : debate.sub_debates[0].id_hash
        when OralAnswers, ParentDebate
          debate.sub_debates[0].id_hash
        else
          debate.id_hash
      end
    else
      nil
    end
  end

  def previous_contribution contribution
    index = contributions.index(contribution)
    if index && index != 0
      contributions[index - 1]
    else
      nil
    end
  end

  def previous_debate
    if can_have_previous
      begin
        prev_index = Debate.to_num_str(index.to_i-1)
        @previous_debate ||= Debate.find_by_index year, month, day, prev_index
      rescue Exception => e
        nil
      end
    else
      nil
    end
  end

  def prev_debate_id_hash
    if can_have_previous && (debate = previous_debate)
      case debate
        when BillDebate, OralAnswers, ParentDebate
          debate.prev_debate_id_hash
        when OralAnswer, SubDebate
          debate.id_hash
        else
          debate.id_hash
      end
    else
      nil
    end
  end

  def contribution_id contribution
    unless index = contribution_index(contribution)
      sub_debates.each do |sub_debate|
        break if index = sub_debate.contribution_index(contribution)
      end if sub_debates
    end
    index ? (index + 1).to_s : nil
  end

  def contribution_index contribution
    (contributions && contributions.include?(contribution)) ? contributions.index(contribution) : nil
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

  def votes
    contributions.select(&:is_vote?).collect(&:vote)
  end

  def geonames
    contributions.collect(&:geonames).flatten.uniq
  end

  CACHE_ROOT = RAILS_ROOT + '/../../shared/cache/views/theyworkforyou.co.nz'

  def update_bill_events
    if bill = find_related_bill
      BillEvent.refresh_events_from_bill(bill)
    end
  end

  def related_bills
    bills = debate_topics.map(&:topic).select{|x| x.is_a?(Bill)}
    if bills.size > 1
      bills
    elsif find_related_bill
      [find_related_bill]
    else
      []
    end
  end

  def find_related_bill
    if id_hash[:bill_url]
      Bill.find_by_url(id_hash[:bill_url])
    elsif debate_topics.empty?
      nil
    elsif debate_topics.first.topic.is_a?(Bill)
      debate_topics.first.topic
    end
  end

  def expire_cached_pages
    return unless is_file_cache?
    hash = id_hash
    year = hash[:year]
    month = hash[:month]
    day = hash[:day]
    index = hash[:index]

    identifier = hash[:url_slug] ? hash[:url_slug] : index
    path_suffix = "#{year}/#{month}/#{day}/#{identifier}"

    path = nil
    if hash[:portfolio_url]
      uncache "/portfolios.cache"
      path = "/portfolios/#{hash[:portfolio_url]}/#{path_suffix}.cache"
    elsif hash[:bill_url]
      uncache "/bills.cache"
      path = "/bills/#{hash[:bill_url]}/#{path_suffix}.cache"
    elsif hash[:committee_url]
      path = "/committees/#{hash[:committee_url]}/#{path_suffix}.cache"
    elsif hash[:url_category]
      path_suffix.sub!("/#{identifier}",'') unless hash[:url_slug]
      path = "/#{hash[:url_category]}/#{path_suffix}.cache"
    else
      path = "/debates/#{path_suffix}.cache"
    end

    path.sub!('/.cache','.cache') if identifier.blank?

    uncache path
    uncache path.sub!("/#{identifier}", '') unless identifier.blank?
    uncache path.sub!("/#{day}", '')
    uncache path.sub!("/#{month}", '')
    uncache path.sub!("/#{year}", '')

    uncache '/debates.cache' unless path.include?('debates')

    unless debate_topics.blank?
      debate_topics.each do |debate_topic|
        if debate_topic.topic.is_a? Bill
          path = "/bills/#{debate_topic.topic.url}.cache"
          uncache path
        end
      end
    end
    uncache '/index.cache'
  end

  protected
    def can_have_previous
      (index != '01') && !(index == '02' && self.is_a?(SubDebate) && parent.sub_debates.size == 1)
    end

    def expire_cached_contributor_pages
      contributions.each do |contribution|
        if (mp = contribution.mp)
          mp.expire_cached_page
        end
      end if is_file_cache?
    end
end
