class BillEvent < ActiveRecord::Base

  belongs_to :bill
  belongs_to :source, :polymorphic => true

  validates_presence_of :name

  after_create :log_creation
  after_save :expire_cached_pages

  class << self

    def create_from_nzl_event nzl_event
      if nzl_event.about_type == 'Bill' && nzl_event.about_id && nzl_event.version_stage
        returning(BillEvent.new) do |e|
          e.bill_id     = nzl_event.about_id
          e.name        = nzl_event.version_stage
          e.date        = nzl_event.version_date
          e.source_type = 'NzlEvent'
          e.source_id   = nzl_event.id
        end
      else
        nil
      end
    end

    def refresh_events_from_bill bill
      create_from_bill(bill).each do |event|
        existing = find_existing event
        unless existing
          event.save!
          event.bill.expire_cached_pages
        end
      end
    end

    def find_existing event
      if event.source_id
        find_by_date_and_name_and_bill_id_and_source_type_and_source_id(event.date, event.name, event.bill_id, event.source_type, event.source_id)
      else
        find_by_date_and_name_and_bill_id(event.date, event.name, event.bill_id)
      end
    end

    def create_from_bill bill
      events = []
      debates_in_groups_by_name = bill.debates_in_groups_by_name

      bill.events_by_date.each do |date_and_stage|
        date = date_and_stage[0]
        stage = date_and_stage[1]

        debates = debates_in_groups_by_name.select {|list| list.first.normalized_name == stage}.flatten

        if debates.blank?
          events << create_from_bill_stage(bill, stage, date)
        else
          debate = debates.sort_by(&:id).last
          events << create_from_bill_debate(bill, stage, debate)
        end
      end

      bill.debates.each do |debate|
        event = BillEvent.find_by_bill_id_and_name_and_date(bill.id, debate.normalized_name, debate.date)
        unless event
          events << create_from_bill_debate(bill, debate.normalized_name, debate)
        end
      end

      events
    end

    def create_from_bill_debate bill, stage, debate
      event = create_from_bill_stage bill, stage, debate.date
      event.source_type = 'Debate'
      event.source_id = debate.id
      event
    end

    def create_from_bill_stage bill, stage, date
      if stage == 'Imprest Supply Debate' && bill.is_appropriation_bill?
        stage = 'Third Reading' if bill.third_reading.to_s == date.to_s
      end
      returning(BillEvent.new) do |e|
        e.bill_id     = bill.id
        e.name        = stage
        e.date        = date
      end
    end

  end

  def date_method
    method = name.downcase.gsub(' ','_').to_sym
    (method == :in_committee) ? :committee_of_the_whole_house : method
  end

  def debates
    debates_in_groups_by_name, votes_by_name = bill.debates_by_name_names_votes_by_name
    debates = if debates_in_groups_by_name.blank?
                []
              else
                debates_in_groups_by_name.select {|list| list.first.normalized_name == self.name}.flatten
              end

    if debates.empty? && bill.is_appropriation_bill?
      debates = debates_in_groups_by_name.select {|list| list.first.normalized_name == 'Imprest Supply Debate'}.flatten
    end

    debates.sort! do |a,b|
      comparison = b.date <=> a.date
      if comparison == 0
        b.id <=> a.id
      else
        comparison
      end
    end if debates
    debates = nil if debates.blank?
    debates
  end

  def votes
    votes_by_name = bill.votes_in_groups_by_name
    votes = votes_by_name.blank? ? nil : votes_by_name[self.name]
    if votes.nil? && bill.is_appropriation_bill?
      votes = votes_by_name.blank? ? nil : votes_by_name['Imprest Supply Debate']
    end

    votes = votes.compact.uniq if votes

    selected_votes = votes.select do |vote|
      if vote_bill_name = vote.bill_name
        bill_name = bill.bill_name
        if bill_name == vote_bill_name ||
            bill_name == vote_bill_name.gsub('’',"'") ||
            bill_name.tr('()','') == vote_bill_name.tr('()','') ||
            vote_bill_name.include?(bill_name) ||
            vote_bill_name.include?(bill_name.sub(' Bill','')) ||
            vote_bill_name.include?(bill_name.sub(' Amendment Bill', ' Bill'))
          true
        else
          begin
            if (found_bill = Bill.from_name_and_date(vote_bill_name, date))
              true
            else
              false
            end
          rescue
            false
          end
        end
      else
        true
      end
    end if votes

    if votes && selected_votes.empty?
      selected_votes = votes.select do |vote|
        if vote_bill_names = vote.bill_names
          bill_name = bill.bill_name
          if vote_bill_names.include?(bill_name)
            reading_result_from_contributions ? false : true
          else
            false
          end
        end
      end
    end

    selected_votes
  end

  def has_debates?
    !debates.blank?
  end

  def has_votes?
    !votes.blank?
  end

  def is_reading_before_nov_2005?
    name && name.include?('Reading') && date < Date.new(2005,11,1)
  end

  def is_first_bill_event?
    bill.is_first_bill_event? self
  end

  def was_split_at_third_reading?
    name == 'Third Reading' && is_first_bill_event?
  end

  def set_created_and_updated_at_date_to_event_date
    if date
      event_date = (date.to_time + (60*60)).utc.beginning_of_day
      if event_date <= Time.now
        self.created_at = event_date
        self.updated_at = event_date
      else
        self.created_at = Time.now.utc unless self.created_at
        self.updated_at = Time.now.utc unless self.updated_at
      end
    end
  end

  def <=> event
    other_date = event.date
    comparison = date <=> other_date
    if comparison == 0
      other_name = event.name
      if name[/Introduction/]
        comparison = -1
      elsif other_name[/Introduction/]
        comparison = +1
      elsif name[/First/] && (other_name[/Second/] or other_name[/Third/])
        comparison = -1
      elsif name[/Second/] && (other_name[/Third/] or other_name[/In Committee/])
        comparison = -1
      elsif name[/Second/] && (other_name[/First/])
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

  def log_creation
    puts "created: #{self.inspect}"
  end

  def expire_cached_pages
    bill.expire_cached_pages
  end

  def result_from_vote helper
    votes = self.votes
    result = votes.compact.collect do |vote|
      result = vote.result
      result = helper.link_to_contribution(result, vote.contribution) if bill_reading?(result)
      result
    end.join('<br /><br />')

    if votes.size == 1
      debate = self.debates.first
      contributions = debate.contributions
      last = contributions.last
      # raise name + ' ' + debate.inspect if last.nil?
      if last.is_procedural?
        if motion_agreed_to? last.text
          result += '<br /><br />' + strip_tags(last.text).chomp('.') + ':<br />'
          if (contributions.size > 1 and contributions[contributions.size-2].is_speech?)
            if match = contributions[contributions.size-2].text.match(/That the .*/)
              result += strip_tags(match[0])
            end
          end
        elsif bill_reading? last.text
          result += '<br /><br />' + strip_tags(last.text)
        else
          result += '<br /><br />' + strip_tags(last.text)
        end
      elsif (contributions.size > 1 and contributions[contributions.size-2].is_procedural?)
        result += '<br /><br />' + strip_tags(contributions[contributions.size-2].text)
      end
    end

    result = make_committee_a_link result, self.bill, helper, votes
    result
  end

  def reading_result_from_contributions helper=nil
    debate = self.debates.first
    bill = self.bill
    if debate.contributions.size == 0
      nil
    else
      contributions = debate.contributions.select{|x| x.is_a?(Procedural)}
      result = contributions.find{|x| x.text[/#{bill.bill_name.gsub('(','\(').gsub(')','\)')} read a \w+ time\.?/]}
      if result
        text = strip_tags result.text
        if helper
          helper.link_to_contribution(text, result)
        else
          text
        end
      else
        nil
      end
    end
  end

  def result_from_contributions helper=nil
    debate = self.debates.first
    bill = self.bill
    if debate.contributions.size == 0
      ''
    else
      contributions = debate.contributions.reverse
      i = 0
      statement = contributions[i]
      results = []

      if motion_agreed_to? statement.text
        result = strip_tags(statement.text).chomp('.') + ':<br />'

        if (contributions.size > 1 and contributions[1].is_speech?)
          if match = contributions[1].text.match(/That the .*/)
            result += strip_tags(match[0]).gsub('</i>','')
          end
        end

        if (contributions.size > 2 and contributions[2].is_procedural?)
          if contributions[2].text.include? 'Bill read'
            result = strip_tags(contributions[2].text) + '<br /><br />' + result
          end
        end

        result.sub!(':<br />','.') if result.ends_with?(':<br />')
      else
        while statement && statement.is_procedural?
          text = strip_tags(statement.text)
          if bill_reading? text
            results << (helper ? helper.link_to_contribution(text, statement) : text)
          else
            results << text unless statement.text[/(Waiata|Sitting suspended)/]
          end
          i = i.next
          statement = (i != contributions.size) ? contributions[i] : nil
          statement = nil if statement && statement.text.include?('House resumed')
          statement = nil if statement && statement.text.gsub('<p>', '').strip[/^(Clause|\[An interpretation)/]
        end
        result = results.reverse.flatten.join('<br /><br />')
      end
      result = make_committee_a_link result, bill, helper if helper
      result
    end
  end

  private

    def bill_reading? text
      strip_tags(text)[/Bills? read a (first|second|third) time\.?/]
    end

    def motion_agreed_to? text
      strip_tags(text) == 'Motion agreed to.'
    end

    def strip_tags text
      text.gsub(/<[pi]>/, '').gsub(/<\/[pi]>/,'')
    end

    def make_committee_a_link result, bill, helper, votes=nil
      if bill
        committee = bill.referred_to_committee
        if (committee and result.include?(committee.full_committee_name))
          name = committee.full_committee_name
          result.sub!(name, helper.link_to(name, helper.show_committee_url(:committee_url => committee.url) ) ) if helper
        elsif (match = (/the (.* Committee)/.match result))
          name = match[1]
          committee = Committee::from_name name
          if committee
            if votes
              votes.each do |vote|
                if (vote.votes_count > 0 and (vote.ayes_count > vote.noes_count))
                  bill.referred_to_committee = committee
                  bill.save
                end
              end
            end
            result.sub!(name, helper.link_to(name, helper.show_committee_url(:committee_url => committee.url) ) ) if helper
          end
        end
      end
      result
    end
end
