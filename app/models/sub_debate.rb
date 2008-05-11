class SubDebate < Debate

  belongs_to :debate
  belongs_to :about, :polymorphic => true

  def full_name
    debate.name + ' - ' + name
  end

  def anchor
    debate.subdebate_id self
  end

  def contribution_id contribution
    debate.contribution_id contribution
  end

  def contribution_index contribution
    if contributions and contributions.include? contribution
      contributions.index contribution
    else
      nil
    end
  end

  def parent
    debate
  end

  def title_name separator=':'
    %Q[#{debate.name}#{separator} #{name}]
  end

  def category
    parent.category
  end

  ##
  # index of next debate
  def next_index
    index.next
  end

  def index_prefix
    'd'
  end

  def about_url
    about.url
  end

  def index_suffix
    index = about_index.to_s if about_index
    index = '0'+index if index.size < 2
    index = index_prefix + index
  end

  def id_hash
    unless about_id.blank?
      hash = {:year => year, :month => month, :day => day, :index => index_suffix}

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

  protected

    def find_by_candidate_slug candidate_slug
      if about && about.is_a?(Bill)
        SubDebate.find_by_url_slug_and_date_and_publication_status_and_about_type_and_about_id(candidate_slug, date, publication_status, about_type, about_id)
      elsif parent
        SubDebate.find_by_url_slug_and_date_and_publication_status(candidate_slug, date, publication_status)
      else
        raise 'unhandled'
      end
    end

    def make_url_slug_text
      if about && about.is_a?(Bill)
        make_bill_url_slug
      elsif parent
        make_sub_debate_url_slug
      else
        nil
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

    def make_sub_debate_url_slug
      case parent.name
        when "Visitors"
          "#{parent.name} #{name.split('—').first}"
        when /Amended Answers to Oral Questions/i
          'amended_answers'
        when 'Appointments'
          "Appointment #{name}"
        else
          parent.name.split('—').first
      end
    end
end
