class SubDebate < Debate

  belongs_to :debate
  belongs_to :about, :polymorphic => true

  def self.all_titles
    a = o.collect(&:major_name).sort.in_groups_by(&:to_s).sort{|a,b| a.size <=> b.size}.reverse; nil
    a.collect{|i| (i.size > 1 && i.first[/Question No/].nil?) ? i.size.to_s + ' ' + i.first : nil }.compact
    a.collect{|i| (i.size > 9 && i.first[/Question No/].nil?) ? ((i.size / o.size.to_f)*100).to_s + ' ' + i.first : nil }.compact
  end

  def bill
    about.is_a?(Bill) ? about : nil
  end

  def major_name
    name.split('—').first
  end

  def minor_name
    name.include?('—') ? name.split('—').last : nil
  end

  def full_name
    debate.name + ' - ' + name
  end

  def anchor
    debate.subdebate_id self
  end

  def contribution_id contribution
    debate.contribution_id contribution
  end

  def parent
    debate
  end

  def parent_name
    parent.name
  end

  def title_name separator=':'
    %Q[#{debate.name}#{separator} #{name}]
  end

  def category
    parent.category
  end

  def next_index
    index.next # index of next debate
  end

  def index_prefix
    'd'
  end

  def about_url
    about ? about.url : ''
  end

  def index_suffix
    index = about_index.to_s if about_index
    index = '0'+index if index.size < 2
    index = index_prefix + index
  end

  def id_hash
    unless about_id.blank?
      hash = {}.merge(date_hash)
      hash.merge!(:url_category => url_category) unless url_category.blank?
      hash.merge!(:url_slug => url_slug) unless url_slug.blank?
      hash.merge!({:index => index_suffix}) if (!url_category.blank? && !url_slug.blank?)

      if about_type == Portfolio.name
        hash.merge :portfolio_url => about_url
      elsif about_type == Committee.name
        hash.merge :committee_url => about_url
      elsif about_type == Bill.name
        hash.merge :bill_url => about_url
      else
        hash
      end
    else
      super
    end
  end

  def parent_name
    parent ? parent.name : ''
  end

  def create_url_slug
    populate_url_category parent_name.gsub(' and ',' ')
    populate_url_slug     make_sub_debate_url_slug_text(self.url_category).gsub(' and ',' ')
    self.url_slug
  end

  def sub_name= text
    unless text[/.*Consideration of.*Report.*/]
      @sub_name = text
      create_url_slug
    end
  end

  protected

    def find_by_candidate_slug candidate_slug
      if about && about.is_a?(Bill)
        SubDebate.find_by_url_slug_and_date_and_publication_status_and_about_type_and_about_id(candidate_slug, date, publication_status, about_type, about_id)
      elsif parent
        SubDebate.find_by_url_category_and_url_slug_and_date_and_publication_status(url_category, candidate_slug, date, publication_status)
      else
        raise 'unhandled'
      end
    end

    def populate_url_category category_text
      unless category_text.blank?
        category = make_slug(category_text) { |candidate_category| nil }
        if Debate::CATEGORIES.include?(category)
          self.url_category = category
        end
      end
    end

    def make_bill_url_slug
      case name
        when /^Consideration of Interim Report.*/
          'consideration_of_interim_report'
        when /^Referral to .* Committee$/
          'referral_to_committee'
        when /^Second Reading\s?Third Reading$/
          'second_and_third_reading'
        else
          String.new name.sub("—",' ')
      end
    end

    def make_sub_debate_url_slug_text url_category
      if about && about.is_a?(Bill)
        make_bill_url_slug
      elsif parent
        if parent.name[/Amended Answers to Oral Questions/i]
          'amended_answers'
        elsif url_category
          if @sub_name
            text = @sub_name.split('—').first
            @sub_name = nil
            text
          else
            name.split('—').first
          end
        else
          parent_name.split('—').first
        end
      else
        nil
      end
    end
end
