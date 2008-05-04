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

end
