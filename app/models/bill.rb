class Bill < ActiveRecord::Base

  belongs_to :member_in_charge, :class_name => 'Mp', :foreign_key => 'member_in_charge_id'
  belongs_to :referred_to_committee, :class_name => 'Committee',:foreign_key => 'referred_to_committee_id'

  belongs_to :formerly_part_of, :class_name => 'Bill', :foreign_key => 'formerly_part_of_id'
  has_many :divided_into_bills, :class_name => "Bill", :foreign_key => 'formerly_part_of_id'
  has_many :debate_topics, :as => :topic
  has_many :sub_debates, :as => :about
  has_many :submissions, :as => :business_item
  has_many :submission_dates
  has_many :nzl_events, :as => :about
  has_many :bill_events, :order => 'date'

  validates_presence_of :bill_name
  validates_presence_of :url
  validates_presence_of :earliest_date
  validates_presence_of :member_in_charge_id

  validates_presence_of :parliament_url
  validates_uniqueness_of :parliament_id, :allow_blank => true

  before_validation :populate_former_name,
      :populate_formerly_part_of,
      :reset_earliest_date,
      :populate_committee

  before_validation_on_create :populate_member_in_charge,
      :default_negatived,
      :create_url_identifier,
      :populate_plain_bill_name,
      :populate_plain_former_name

  after_save :expire_cached_pages

  include ExpireCache

  class << self

    def bill_names text
      bill_text = text.to_s
      bill_text.gsub!(/(\d)\), Te/, '\1), the Te')
      bill_text.gsub!(/Bill( \(No \d+\))? and the/,'Bill\1, and the')
      bill_text.gsub!(/Bill( \([^\)]+\))? and the/,'Bill\1, and the')
      bill_text.gsub!(/\sbe now read a (\w+) time and the /, ', and the ')

      bills = bill_text.split(/,( and)? the/)
      bills = bills.select { |b| b.match(/[a-z ]*(.*)/)[1].length > 0 }
      bills.collect { |b| b.match(/[a-z ]*(.*)/)[1].chomp(', ').strip }
    end

    def parliament_id parliament_url
      parliament_url.split('/').last.split('.').first
    end

    def passed_third_reading_no_vote
      readings = BillEvent.find(:all, :conditions => 'name like "%Third%"'); nil
      readings = Parliament.find(48).in_parliament(readings); nil
      no_vote_readings = readings.select {|x| !x.has_votes?}; nil
      bills = no_vote_readings.collect(&:bill).uniq; nil
      parent_bills = bills.collect {|b| b.formerly_part_of_id ? b.formerly_part_of : b}.uniq; nil
      parent_bills
    end

    def all_bill_names
      @all_bill_names = Bill.find_by_sql('select distinct bill_name from bills').collect(&:bill_name).sort.reverse unless @all_bill_names
      @all_bill_names
    end

    def bills_from_text_and_date text, date
      bills = bill_names(text).collect do |name|
        name.empty? ? nil : Bill.from_name_and_date(name, date)
      end.compact
    end

    def from_name_and_date name, date
      from_name_and_date_by_method name, date, :find_all_by_bill_name
    end

    def find_all_by_plain_bill_name_and_year name, year
      bills = find_all_by_plain_bill_name name
      bills = find_all_by_plain_former_name name if bills.empty?
      selected = select_by_year bills, year
      selected = select_by_year bills, (year-1) if selected.empty?
      selected = select_by_year bills, (year-2) if selected.empty?
      selected
    end

    def select_by_year bills, year
      selected = bills.select do |b|
        introduced_that_year = b.introduction && b.introduction.year == year
        if introduced_that_year
          true
        elsif (formerly = b.formerly_part_of)
          formerly.introduction && formerly.introduction.year == year
        else
          false
        end
      end
    end

    CORRECTIONS = [
      ['Appropriation (2005/06) Supplementary Estimates Bill', 'Appropriation (2005/06 Supplementary Estimates) Bill'],
      ['Limited Partnerships Bill be now read a third time and the Taxation (Limited Partnerships) Bill', 'Limited Partnerships Bill'],
      ['Public Transport Amendment Bill', 'Public Transport Management Bill'],
      ['Social Security (Entitlement Cards) Amendment', 'Social Security (Entitlement Cards) Amendment Bill'],
      ['Parole (Extended Supervision Orders) Bill', 'Parole (Extended Supervision Orders) Amendment Bill'],
      ['Employment Relations (Minimum Redundancy Entitlements) Amendment Bill', 'Employment Relations (Statutory Minimum Redundancy Entitlements) Amendment Bill'],
      ['Cluster Munitions (Prohibition) Bill', 'Cluster Munitions Prohibition Bill'],
      ['Telecommunications (TSO, Broadband, and Other Matters) Amendment Bill','Telecommunications (TSO, Broadband and Other Matters) Amendment Bill'],
      ['2009/2010','2009/10'],
      ['Employment Relations (Film Production) Amendment Bill','Employment Relations (Film Production Work) Amendment Bill'],
      ['Research, Science and Technology Amendment Bill','Research, Science, and Technology Bill'],
      ['Customs and Excise (Prohibition of Goods Made by Slave Labour) Amendment Bill','Customs and Excise (Prohibition of Imports Made by Slave Labour) Amendment Bill'],
      ['Electoral (Reduction in Number of Members of Parliament) Bill','Electoral (Reduction in Number of Members of Parliament) Amendment Bill'],
      ['Bill of Rights (Private Property Rights) Amendment Bill', 'New Zealand Bill of Rights (Private Property Rights) Amendment Bill'],
      ['Subordinate Legislation (Confirmation and Validation Bill (No 2)','Subordinate Legislation (Confirmation and Validation) Bill (No 2)'],
      ['Births, Death, Marriages, and Relationships Registration Amendment Bill','Births, Deaths, Marriages, and Relationships Registration Amendment Bill'],
      ['Telecommunications (TSO, Broadband and Other Matters) Amendment Bill','Telecommunications (TSO, Broadband, and Other Matters) Amendment Bill'],
      ['Aquaculture Legislation Amendment Bill (No. 3)','Aquaculture Legislation Amendment Bill (No 3)'],
      [') Estimates)',' Estimates)'],
      ['20010/11','2010/11']
    ]
    def from_name_and_date_by_method name, date, method
      name = name.sub('Hearing of evidence on the ','')
      bills = send(method, name)
      bills = send(method, name.gsub('-',' - ')) if bills.empty?
      bills = send(method, name.gsub('’',"'")) if bills.empty?
      bills = send(method, name.gsub('’','')) if bills.empty?
      bills = send(method, name.gsub('’',"'").chomp(')')) if bills.empty?
      bills = send(method, name.gsub('’',"'").chomp(')').sub(')',') ').sub('(',' (').squeeze(' ')) if bills.empty?
      bills = send(method, name.gsub('’',"'").chomp(')').sub(')',') ').sub('(',' (').squeeze(' ').sub('Appropriations','Appropriation')) if bills.empty?
      bills = send(method, name.gsub('’',"'").chomp(')').sub(')',') ').sub('(',' (').squeeze(' ').sub('RateAmendments','Rate Amendments')) if bills.empty?
      bills = send(method, name.gsub('’',"'").chomp(')').sub(')',') ').sub('(',' (').squeeze(' ').sub('andAsure','and Asure')) if bills.empty?

      if bills.empty?
        CORRECTIONS.each do |old_text, new_text|
          bills = send(method, name.sub(old_text, new_text)) if bills.empty?
        end
      end

      bills = bills.select {|b| b.royal_assent.nil? || (b.royal_assent >= date) }
      bills = bills.select do |b|
        if b.introduction.nil? && b.earliest_date.nil?
          true
        elsif b.introduction.nil?
          select = b.earliest_date <= date ? true : false
          if !select && b.formerly_part_of
            select = (b.formerly_part_of.earliest_date && b.formerly_part_of.earliest_date <= date) ? true : false
          end
          select
        elsif b.earliest_date.nil?
          b.introduction <= date ? true : false
        elsif b.earliest_date <= date || b.introduction <= date
          true
        else
          false
        end
      end

      if bills.size == 1
        bills[0]
      elsif bills.empty?
        if method == :find_all_by_bill_name
          from_name_and_date_by_method name, date, :find_all_by_former_name
        elsif name == 'Resource Management (Simplifying and Streamlining) Amendment Bill' ||
            name == 'Local Government (Auckland Law Reform) Bill' ||
            name == 'Domestic Violence (Enhancing Safety) Bill' ||
            name == 'Climate Change (Emissions Trading and Renewable Preference) Bill' ||
            name == 'Corrections (Contract Management of Prisons) Amendment Bill'
          Bill.find_by_bill_name(name)
        else
          raise "no bills match: #{name}, #{date.to_s}"
        end
      else
        begin
          the_date = date
          if the_date.is_a? String
            the_date = Date.parse(date)
          end
          days_back = bills.select{|b| the_date >= b.earliest_date}.collect {|b| [(the_date - b.earliest_date).to_i, b] }
          bill = days_back.sort.first[1]
          bill
        rescue Exception => e
          raise "#{bills.size} bills match: #{name}, #{date.to_s}"
        end
      end
    end

    def find_all_current
      sql = 'select * from bills where royal_assent is null and first_reading_negatived = 0 and second_reading_negatived = 0 and withdrawn is null and second_reading_withdrawn is null and committal_discharged is null and consideration_of_report_discharged is null and second_reading_discharged is null and first_reading_discharged is null'
      sql += %Q[ and type = "#{self.to_s}"] unless self == Bill
      bills = find_by_sql(sql)
      bills.select { |b| b.current? && b.url != 'business_law_reform' }
    end

    def find_all_negatived
      find_all_with_debates.select(&:negatived?)
    end

    def find_all_assented_by_parliament
      assented = find_all_with_debates.select(&:assented?)
      by_parliament = []
      parliaments = Parliament.all.sort_by(&:id).reverse
      parliaments.each do |parliament|
        assented_during_parliament = assented.select{|x| parliament.date_within?(x.royal_assent) }
        assented_during_parliament = assented_during_parliament.collect {|b| b.formerly_part_of_id ? b.formerly_part_of : b}.uniq
        by_parliament << [parliament, assented_during_parliament]
      end
      by_parliament
    end

    def sort_events_by_date events
      events.sort do |a,b|
        date, name = yield a
        other_date, other_name = yield b
        comparison = date <=> other_date
        if comparison == 0
          if (name[/Introduction/])
            comparison = -1
          elsif (other_name[/Introduction/])
            comparison = +1
          elsif (name[/First/] and (other_name[/Second/] or other_name[/Third/]))
            comparison = -1
          elsif (name[/Second/] and (other_name[/Third/]))
            comparison = -1
          elsif (name[/Second/] and (other_name[/First/]))
            comparison = +1
          elsif name[/In Committee/] && (other_name[/First/] or other_name[/Second/])
            comparison = +1
          elsif name[/In Committee/] && (other_name[/Third/])
            comparison = -1
          elsif name[/Third/] && (other_name[/First/] or other_name[/Second/] or other_name[/In Committee/] )
            comparison = +1
          else
            comparison = 0
          end
        end
        comparison
      end
    end
  end

  def query_for_search
    name = %Q|"#{bill_name}"|
    words = name.split(' ').size
    if words > 6
      name = name.gsub(' Bill','')
      name = name.gsub(' Amendment','')
    end
    if words < 4
      name += ' site:nz'
    end
    name
  end

  def news_items
    begin
      url = "http://news.google.co.nz/news?hl=en&ned=nz&ie=UTF-8&scoring=n&q=#{URI.escape(query_for_search)}&output=atom"

      xml = open(url).read
      results = Morph.from_hash(Hash.from_xml(xml.gsub('id>','id_name>').gsub('type=','type_name=')))
      results.entries = [results.entry] if results.respond_to?(:entry) && results.entry
      results.entries = [] if !results.respond_to?(:entries) || results.entries.blank?

      results.entries.each do |e|
        doc = Hpricot "<html><body>#{e.content}</body></html>"
        e.author = doc.at('font[@color="#6f6f6f"]').inner_text
        e.publisher = e.author.split(',')[0]
        e.full_title = e.title
        e.title = doc.at('a').inner_text
        e.title = e.full_title.sub(e.publisher,'').strip.chomp('-') if e.title.blank?
        e.content = doc.at('font[@size="-1"]:eq(1)').to_s
        e.published_date = e.issued
        e.display_date = Date.parse(e.published_date).to_s(:long)
        e.url = e.link.href
      end

      results.entries.sort_by {|x| Date.parse(x.published_date) }.reverse
    rescue Exception => e
      raise e
      nil
    end
  end

  def blog_items
    begin
      url = "http://blogsearch.google.co.nz/blogsearch_feeds?hl=en&scoring=d&q=#{URI.escape(query_for_search)}&ie=utf-8&num=10&output=atom"

      xml = open(url).read
      results = Morph.from_hash(Hash.from_xml(xml.gsub('id>','id_name>').gsub('type=','type_name=')))
      results.entries = [results.entry] if results.respond_to?(:entry) && results.entry
      results.entries = [] if !results.respond_to?(:entries) || results.entries.blank?

      results.entries.each do |e|
        e.full_title = e.title
        if (split = e.title.split('|')).size == 2
          e.title = split[0]
          e.author.name = split[1]
        end
        if e.author.name[/unknown|Anonymous|nospam@example\.com/i]
          e.author.name = e.author.uri.sub('http://','').sub('www.','').chomp('/')
        end
        e.publisher = e.author.name
        e.published_date = e.published
        e.display_date = Date.parse(e.published_date).to_s(:long)
        e.url = e.link.href
        e.content = %Q|<font size="-1">#{e.content.sub('Contents; « Previous · Next » · Search within this Bill.','')}</font>|
      end

      # results.entries.delete_if {|x| x.publisher[/example\.com/]}
      results.entries.sort_by {|x| Date.parse(x.published_date) }.reverse
    rescue Exception => e
      raise e
      nil
    end
  end

  def fix_debate_topics
    topics = unmatched_debate_topics
    if topics.size > 0
      bills = Bill.find_all_by_bill_name(self.bill_name)
      other_bill = bills.detect {|b| b.id != self.id}
      topics.each do |topic|
        if other_bill.send(:third_reading) == topic.debate.date
          puts 'found match for: ' + topic.debate.name + ' ' + other_bill.bill_name
          topic.topic_id = other_bill.id
          topic.save
        else
          puts 'no match for: ' + topic.debate.name + ' ' + other_bill.bill_name
        end
      end
    end
  end

  def unmatched_debate_topics
    topics = []
    if Bill.find_all_by_bill_name(self.bill_name).size == 2
      debate_topics.each do |topic|
        debate = topic.debate
        if debate.name.include?('Third')
          if third_reading != debate.date
            begin
              days = (debate.date - third_reading)
              if days > 5
                topics << topic
              end
            rescue
              dates = third_reading.to_s + ' ' + debate.date.to_s
              # puts 'found match for: ' + debate.name + ' ' + self.bill_name + ' ' + dates
            end
          end
        end
      end
    end
    topics
  end

  def fix_bill_events
    unmatched = unmatched_bill_events
    if unmatched.size > 0
      bills = Bill.find_all_by_bill_name(self.bill_name)
      other_bill = bills.detect {|b| b.id != self.id}

      unmatched.each do |event|
        if other_bill.send(event.date_method) == event.date
          puts 'found match for: ' + event.name + ' ' + other_bill.bill_name
          event.bill_id = other_bill.id
          event.save
        end
      end
    end
  end

  def unmatched_bill_events
    events = []
    if Bill.find_all_by_bill_name(self.bill_name).size == 2
      dates = [introduction, first_reading, second_reading,
            committee_of_the_whole_house, third_reading, royal_assent].compact.sort
      events = bill_events.select {|e| e.source_type == 'Debate'}
      events = events.select {|e| !dates.include?(e.date)}
      events = events.select do |e|
        if date = self.send(e.date_method)
          e.date > date
        else
          true
        end
      end
    end
    events
  end

  def probably_not_divided?
    year = Date.today.year
    divided_into_bills.empty? or (divided_into_bills.size > 0 and (last_event and (last_event[0].year == year || last_event[0].year == year-1) ))
  end

  def missing_events?
    events = top_level_bill_events.collect(&:name)
    readings = debates.collect(&:name).select{|x| x[/Reading/]}.collect{|x| x.singularize}
    missing = readings - events
    !missing.empty?
  end

  def current?
    is_current = ( (not(negatived? or assented? or withdrawn? or discharged?)) and probably_not_divided? )
    if divided_into_bills.empty?
      is_current
    else
      divided_into_bills.inject(is_current) {|current, bill| current && bill.current?}
    end
  end

  def full_name
    if url[/_(\d\d\d\d)$/]
      "#{bill_name} #{$1}"
    else
      bill_name
    end
  end

  def is_appropriation_bill?
    bill_name[/^Appropriation/]
  end

  def negatived?
    first_reading_negatived or second_reading_negatived
  end

  def assented?
    royal_assent ? true : false
  end

  def is_before_committee?
    referred_to_committee and referred_to_committee.bills_before_committee.include?(self)
  end

  def was_reported_by_committee?
    referred_to_committee and referred_to_committee.reported_bills.include?(self)
  end

  def last_event
    events_by_date.last
  end

  def last_event_date
    last_event ? last_event[0] : nil
  end

  def last_event_name
    last_event ? last_event[1] : nil
  end

  def party_in_charge
    member_in_charge ? member_in_charge.party : nil
  end

  def last_event_debates
    debates = debates_in_groups_by_name
    if debates.blank?
      nil
    else
      name = last_event.name
      debates.select{|list| list.first.normalized_name == name}.flatten
    end
  end

  def debates
    if debate_topics.size > 0
      sub_debates + debate_topics.collect { |t| t.debate }
    else
      sub_debates
    end
  end

  def debate_count
    [count_by_about('U'), count_by_about('A'), count_by_about('F')].max
  end

  def has_debates?
    !debates.empty?
  end

  def debates_in_groups_by_name
    if has_debates?
      Debate.debates_in_groups_by_name debates
    else
      []
    end
  end

  def votes_in_groups_by_name
    in_groups_by_name = debates_in_groups_by_name
    get_votes_by_name in_groups_by_name
  end

  def votes_by_name
    if has_debates?
      in_groups_by_name = debates_in_groups_by_name
      votes_by_name = get_votes_by_name in_groups_by_name
      return in_groups_by_name, votes_by_name
    else
      return nil, nil
    end
  end

  def have_votes?
    # votes_by_name = votes_in_groups_by_name
    have_votes = false
    bill_events.each do |bill_event|
      # votes = votes_by_name.blank? ? nil : votes_by_name[bill_event.name]
      votes = bill_event.votes
      have_votes = (votes && !votes.empty?) || bill_event.is_reading_before_nov_2005?
      break if have_votes
    end
    have_votes
  end

  def debates_by_name_names_votes_by_name
    in_groups_by_name, votes_by_name = self.votes_by_name
    return in_groups_by_name, votes_by_name
  end

  def is_missing_votes?
    missing_votes = false
    bill_events.each do |bill_event|
      if bill_event.is_reading_before_nov_2005?
        missing_votes = true
        break
      end
    end
    missing_votes
  end

  def is_first_bill_event? bill_event
    bill_event == bill_events.last
  end

  def top_level_bill_events
    events = bill_events.compact # copy bill_events
    events.delete_if {|e| e.source && !e.source.is_a?(Debate) }
    events = bill_events if events.empty?
    events = events.group_by(&:name)
    top_level = []
    events.each do |name, matching|
      with_debates = matching.select {|e| e.source.is_a?(Debate)}
      if with_debates.empty?
        top_level << matching.first
      else
        top_level << with_debates.first
      end
    end

    events = top_level.compact.sort.reverse
    events
  end

  def events_by_date
    events = []
    events << [introduction, 'Introduction'] if introduction
    events << [first_reading, 'First Reading'] if first_reading
    events << [sc_reports, 'SC Reports'] if sc_reports
    events << [submissions_due, 'Submissions Due'] if submissions_due
    events << [second_reading, 'Second Reading'] if second_reading
    events << [committee_of_the_whole_house, 'In Committee'] if committee_of_the_whole_house
    events << [third_reading, 'Third Reading'] if third_reading
    events << [royal_assent, 'Royal Assent'] if royal_assent

    events << [withdrawn, 'Withdrawn'] if withdrawn
    events << [second_reading_withdrawn, 'Second reading withdrawn'] if second_reading_withdrawn
    events << [committal_discharged, 'Committee of the whole House: Order of the day for committal discharged'] if committal_discharged
    events << [consideration_of_report_discharged, 'Consideration of report: Order of the day for consideration of report discharged'] if consideration_of_report_discharged
    events << [second_reading_discharged, 'Second reading: Order of the day for second reading discharged'] if second_reading_discharged
    events << [first_reading_discharged, 'First reading: Order of the day for first reading discharged'] if first_reading_discharged

    Bill.sort_events_by_date(events) {|e| [e[0],e[1]]}
  end

  def populate_plain_bill_name
    self.plain_bill_name = strip_name(bill_name) if bill_name
  end

  def populate_plain_former_name
    self.plain_former_name = strip_name(former_name) if former_name
  end

  def strip_name name
    name.tr("-:/,'",'').gsub('(','').gsub(')','').gsub('’','')
  end

  def expire_cached_pages
    return unless is_file_cache?

    uncache "/bills/#{url}.cache"
    uncache "/bills/#{url}.atom.atom.cache"

    if referred_to_committee
      uncache "/committees/#{referred_to_committee.url}.cache"
    end

    if member_in_charge
      uncache "/mps/#{member_in_charge.id_name}.cache"
    end

    uncache "/bills.cache"
    uncache "/bills.atom.atom.cache"
  end

  def id_hash
    { :bill_url => url }
  end

  protected

    def self.find_all_with_debates
      bills = find(:all, :include => [:sub_debates, {:debate_topics => :debate}])
      bills.select { |b| b.debate_count > 0 or b.debate_topics.size >  0 }
    end

    def count_by_about publication_status
      debate_count = sub_debates.select {|d| d.publication_status == publication_status }.size
      debate_count + debate_topics.select {|t| t.debate.publication_status == publication_status }.size
    end

    def get_votes_by_name debates_in_groups_by_name
      debates_in_groups_by_name.inject({}) do |by_name, list|
        debate = list.first
        votes = debate.votes.select { |v| v && v.question[/be (now )?read/] }
        if votes.empty?
          votes = debate.votes.select { |v| v && v.result.include?('Bill referred') }
        else
          contributions = debate.contributions
          if (contributions.last and contributions.last.is_vote?)
            vote = contributions.last.vote
            if (vote != votes[0])
              votes << vote
            end
          end
        end

        if (votes.empty?)
          contributions = debate.contributions
          if (contributions.last)
            last = contributions.last
            if (last.is_vote?)
              votes = [last.vote]
            elsif ((last.text[/Bill to be reported without amendment presently./] or
              last.text[/Bill referred to/]) and
              contributions[contributions.size-2].is_vote?)
              votes = [contributions[contributions.size-2].vote]
            end
          end
        end
        by_name[debate.normalized_name] = votes.empty? ? nil : votes
        by_name
      end
    end

    def withdrawn?
      (withdrawn or second_reading_withdrawn) ? true : false
    end

    def committal_discharged?
      committal_discharged ? true : false
    end

    def consideration_of_report_discharged?
      consideration_of_report_discharged ? true : false
    end

    def second_reading_discharged?
      second_reading_discharged ? true : false
    end

    def first_reading_discharged?
      first_reading_discharged ? true : false
    end

    def discharged?
      committal_discharged? or consideration_of_report_discharged? or second_reading_discharged? or first_reading_discharged?
    end

    def referred_to= name
      @referred_to = name
    end

    def referred_to
      @referred_to
    end

    def mp_name= name
      @mp_name = name
    end

    def mp_name
      @mp_name
    end

    def bill_change= change
      @bill_change = change
    end
  public
    def bill_change
      @bill_change
    end
  protected
    def populate_former_name
      if bill_change and not(bill_change[/Formerly part of/]) and (bill_change[/Formerly /])
        self.former_name = bill_change.gsub('(Formerly ','').chomp(')')
      end
    end

    def populate_formerly_part_of
      if formerly_part_of.blank?
        if bill_change and bill_change[/Formerly part of/]
          former = bill_change.gsub('(Formerly part of ', '').chomp(')')
          if former_bill = Bill.find_by_bill_name(former)
            self.formerly_part_of_id = former_bill.id
          else
            raise 'Validation failed: cannot find former bill from bill_change: ' + bill_change
          end
        end
      end
    end

    def populate_committee
      if referred_to_committee_id.blank?
        if referred_to
          name = referred_to.gsub(/M.*ori /, 'Maori ')
          if (committee = Committee.from_name name)
            self.referred_to_committee_id = committee.id
          else
            raise 'Validation failed: cannot find committee from referred_to: ' + referred_to
          end
        end
      end
    end

    def populate_member_in_charge
      if member_in_charge_id.blank?
        if mp_name
          mp = Mp.from_name(mp_name, Date.today)
          if mp
            self.member_in_charge_id = mp.id
          else
            raise 'Validation failed: cannot find member in charge from mp_name: ' + mp_name
          end
        else
          raise 'Validation failed: :mp_name can\'t be blank'
        end
      end
    end

  public
    def reset_earliest_date
      self.introduction = '2008-07-02' if bill_name == 'Privacy (Cross-border Information) Amendment Bill'

      dates = [introduction, first_reading, second_reading,
          committee_of_the_whole_house, third_reading, royal_assent].compact.sort
      if dates.size > 0
        self.earliest_date = dates.first
      elsif formerly_part_of_id != nil
        parent_bill = Bill.find(formerly_part_of_id)
        if (date = parent_bill.earliest_date)
          self.earliest_date = date
        end
      end
    end

    def populate_parliament_id
      self.parliament_id = Bill.parliament_id(parliament_url) if parliament_id.blank?
    end

  protected
    def default_negatived
      self.first_reading_negatived = 0 unless self.first_reading_negatived
      self.second_reading_negatived = 0 unless self.second_reading_negatived
    end

    def create_url_identifier
      if bill_name and not url
        url = bill_name.to_latin.to_s.downcase.
            tr(',:','').gsub('(','').gsub(')','').
            gsub('’','').
            gsub('/ ',' ').tr('/',' ').
            gsub(/ng\S*ti/, 'ngati').
            tr("'",'').gsub(' and', '').
            gsub('new zealand', 'nz').
            gsub(' bill', '').
            gsub(' miscellaneous', '').
            gsub(' provisions', '').
            gsub(' as a','').gsub(' - ','-').
            gsub('  ',' ').tr(' ','_')

        num = /.*(_no_.*)/.match url

        if url.size > 40
          cut_off = url[40..40]
          in_word = /[A-Za-z0-9]/.match cut_off

          url = url[0..39]

          if in_word
            url = url[0..(url.rindex('_')-1)]
          end
        end

        if num and not url.include? num[1]
          if url.size < 35
            url = url + num[1]
          else
            url = url[0..34].chomp('_')+num[1]
          end
        end

        bill = Bill.find_by_url(url)

        if bill
          self.url = "#{url}_#{earliest_date.year.to_s}"
        else
          self.url = url
        end
      end
    end

end
