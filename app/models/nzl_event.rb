require 'morph'

class NzlEvent < ActiveRecord::Base

  belongs_to :about, :polymorphic => true

  before_validation_on_create :populate_publication_date, :populate_description_data
  after_create :create_bill_event, :clean_cache

  class << self

    def all_act_names
      @all_act_names = find_all_by_information_type('act').collect(&:title).compact.sort.uniq unless @all_act_names
      @all_act_names
    end

    def create_from params
      publication_date = NzlEvent.parse_pub_date params[:pub_date]
      existing = NzlEvent.find_all_by_title(params[:title])
      if existing.empty?
        puts 'creating ' + params[:title] + ' (' + publication_date.to_s + ')' if RAILS_ENV != 'test'
        NzlEvent.create params
      else
        event = NzlEvent.new params
        saved_event = nil
        if event.valid?
          new_attributes = event.attributes.merge({'publication_date'=>nil, 'id'=>nil})
          should_ignore = false

          existing.each do |old_event|
            old_attributes = old_event.attributes.merge({'publication_date'=>nil, 'id'=>nil})
            should_ignore = true if (old_attributes == new_attributes)
          end

          unless should_ignore
            puts 'creating ' + params[:title] + ' (' + publication_date.to_s + ')' if RAILS_ENV != 'test'
            event.save!
            saved_event = event
          end
        end

        saved_event
      end
    end

    def remove_duplicates
      dups = find(:all).sort_by(&:title).in_groups_by(&:title).select{|g| g.size > 1}
      dups.each do |list|
        keep = list.sort.reverse.uniq.collect(&:id)
        list.each do |event|
          unless keep.include? event.id
            puts 'deleting ' + event.id.to_s
            event.destroy
          end
        end
      end
      nil
    end
  end
=begin
  def == other
    attributes_less_id == other.attributes_less_id
  end

  def attributes_less_id
    fields = {}.merge(attributes)
    fields.delete('id')
    fields
  end

  def eql?(object)
    self == (object)
  end

  def hash
    nzl_id.hash
  end

  def <=> other
    if self == other
      0
    else
      id <=> other.id
    end
  end
=end
  protected
    def description
      @description
    end

    def description= description
      @description = description
    end

    def pub_date
      @pub_date
    end

    def pub_date= pub_date
      @pub_date = pub_date
    end

    def populate_publication_date
      if pub_date
        self.publication_date = NzlEvent.parse_pub_date pub_date
      end
    end

    def self.parse_pub_date pub_date
      Time.parse(pub_date.sub(' NZST',''))
    end

    def create_bill_event
      event = BillEvent.create_from_nzl_event(self)
      event.save! if event
    end

    def clean_cache
      if about_type == 'Bill' && about
        bill = about
        bill.expire_cached_pages
      end
    end
public

    CORRECTIONS = [
      ['Cluster Munitions Prohibition Prohibition Bill','Cluster Munitions Prohibition Bill'],
      ['Sale of Liquor Youth Alcohol Harm Reduction Television Broadcasting Promotion Amendment Bill','Sale of Liquor Youth Alcohol Harm Reduction Amendment Bill'],
      ['Taxation Personal Tax Cuts Annual Rates and Remedial Matters Bill 2008','Taxation Personal Tax Cuts Annual Rates and Remedial Matters Bill']
    ]
    def populate_bill
      if self.about_type == 'Bill' && about_id.nil?
        name = self.title
        CORRECTIONS.each do |old_text, new_text|
          name = name.sub(old_text, new_text)
        end

        bills = Bill.find_all_by_plain_bill_name_and_year(name, self.year)
        bills = Bill.find_all_by_plain_bill_name_and_year(name, self.year + 1) if bills.empty?

        if bills.size == 1
          bill = bills.first
          self.about_id = bill.id
        elsif self.title == 'New Zealand Security Intelligence Service Amendment Bill' && self.year.to_s == '2010'
          self.about_id = bills.last.id
        elsif bills.size > 0
          raise 'more than one matching bill for ' + self.title + ' ' +
              self.year.to_s + ': ' + bills.inspect
        else
          require 'yaml'
          y self.attributes
          puts "\ndidn't find Bill for event: " + self.title + ', ' + self.year.to_s + ' (' + self.publication_date.to_s + ')'
        end
      end
    end

    def populate_about_information event
      if event.information_type == 'bill'
        self.about_type = 'Bill'
      end
    end

    def populate_version_information event
      version = event.respond_to?(:version) ? event.version : nil
      return unless version
      if (match = /(.+)\s+from the\s+(.+)\s+on\s+(.+)/.match version)
        self.version_stage = match[1].strip.downcase.squeeze(' ')
        committee_name = match[2].strip
        self.version_committee = committee_name
        if (committee = Committee.from_name(committee_name))
          self.committee_id = committee.id
        end
        self.version_date = Date.parse(match[3].strip)
      elsif (match = /(.+)\s+(\d\d?\s\S+\s\d\d\d\d)/.match version)
        self.version_stage = match[1].strip.downcase
        self.version_date = Date.parse(match[2].strip)
      end
    end

    def populate_description_data
      if description
        parts = description.gsub("\r",'').gsub("\n",'').gsub('&lt;','<').gsub('&gt;','>').split('<br />').collect {|p| p.split(': ')}
        event = NzlEventProxy.new
        parts.each do |part|
          field = part[0].downcase.gsub(' ','_').strip
          field = 'nzl_id' if field == 'id'
          event.morph(field, part[1])
        end

        self.status = event.status.downcase
        self.nzl_id = event.nzl_id
        self.legislation_type = event.legislation_type
        self.information_type = event.information_type
        self.year = event.year.to_i
        self.no = event.no
        if event.respond_to?(:current_as_at_date)
          match = /(\d\d)\/(\d\d)\/(\d\d\d\d)/.match event.current_as_at_date
          self.current_as_at_date = Date.new(match[3].to_i,match[2].to_i,match[0].to_i) if match
        end

        populate_about_information event
        populate_bill
        populate_version_information event
        self.link = self.link.sub('www.','')
      end
    end
end

class NzlEventProxy

  include Morph

end
