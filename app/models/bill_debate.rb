class BillDebate < ParentDebate

  alias_method :original_populate_sub_debate, :populate_sub_debate

  before_create :populate_about_index

  class << self
    def recent
      debates = find(:all,
          :order => "debates.`date` DESC",
          :limit => 20,
          :include => :sub_debates)
      debates = Debate::remove_duplicates debates, false
      debates.collect {|d| d.sub_debates}.flatten.sort {|a,b| b.date <=> a.date}
    end

    def recent_grouped
      debates = find(:all,
          :order => "debates.`date` DESC",
          :limit => 20,
          :include => :sub_debates)
      debates = Debate::remove_duplicates debates, false
      debates = debates.sort_by(&:name)
      groups = debates.in_groups_by{|d| (d.sub_debate and d.sub_debate.about) ? d.sub_debate.about : d.name}
      groups.each do |group|
        group.sort! do |debate, other|
          comp = debate.date <=> other.date
          if comp == 0
            (debate.sub_about_index || 0) <=> (other.sub_about_index || 0)
          else
            comp
          end
        end
      end
      groups
    end
  end

  def sub_about_index
    sub_debates.first.about_index
  end

  def category
    'bill debate'
  end

  def bill
  end

  protected

    def find_by_candidate_slug candidate_slug
      BillDebate.find_by_url_slug_and_date_and_publication_status_and_about_type_and_about_id(candidate_slug, date, publication_status, about_type, about_id)
    end

    def make_url_slug_text
      if sub_debate && sub_debate.name
        text = sub_debate.name
      else
        text = String.new name
      end
    end

    def populate_sub_debate type=SubDebate
      if @sub_names
        original_populate_sub_debate type
        populate_about
      end
    end

    def populate_about
      if css_class == 'billdebate'
        bill = Bill.from_name_and_date name, date

        sub_debates.each do |sub|
          sub.about_type = Bill.name
          sub.about_id = bill.id
        end
      elsif css_class == 'billdebate2' || css_class == 'billdebate_mid'
        name = String.new self.name
        name.gsub!(' ,',',')
        while (match = /Bill\s(\(No\s\d+\))/.match name)
          name.sub!(match[0], match[1]+' Bill')
        end
        names = name.split('Bill,')
        bills = names.collect do |name|
          name = name.chomp('Bill').strip + ' Bill'
          while (match = /(\(No\s\d+\))\sBill/.match name)
            name.sub!(match[0], 'Bill ' + match[1])
          end
          Bill.from_name_and_date(name, date)
        end
        topics = bills.collect { |bill| DebateTopic.new :topic_type => Bill.name, :topic_id => bill.id }

        sub_debates.each { |sub| sub.debate_topics = topics }
      else
        raise 'unexpected css_class: ' + css_class
      end
    end

    def populate_about_index
      if css_class == 'billdebate'
        bill = Bill.from_name_and_date name, date
        others = SubDebate.find_all_by_date_and_about_id_and_about_type_and_publication_status(date, bill.id, Bill.name, publication_status)
        if (others and others.size > 0)
          last_index = others.collect {|d| d.about_index}.sort.last
        else
          last_index = 0
        end
        sub_debates.each_with_index do |sub, index|
          about_index = last_index + index + 1
          sub.about_index = about_index
        end
      end
    end
end
