class DebateAlone < Debate

  belongs_to :about, :polymorphic => true

  def bill
    formerly_about_bill
  end

  def full_name
    name
  end

  def category
    'debate'
  end

  def next_index
    index.next
  end

  def create_url_slug
    major, minor = name.split("—")
    populate_url_category major.strip.gsub(' and ',' ')
    if self.url_category
      if minor
        populate_url_slug minor.strip
      else
        debates = Debate.find_all_by_url_category_and_date_and_publication_status(url_category, date, publication_status)
        debates.delete_if {|d| d.url_slug && !d.url_slug.starts_with?('part_')}
        debates = debates.sort_by(&:debate_index)
        if debates.size > 1 && (index = debates.index(self))
          self.url_slug = "part_#{index+1}"
        else
          self.url_slug = nil
        end
      end
    else
      populate_url_slug make_url_slug_text.gsub(' and ',' ')
    end
    self.url_slug
  end

  protected
    def find_by_candidate_slug candidate_slug
      Debate.find_by_url_category_and_url_slug_and_date_and_publication_status(url_category, candidate_slug, date, publication_status)
    end

    def populate_url_category category_text
      category_text = 'Members Sworn' if category_text == 'Member Sworn'
      category_text = 'Maiden Statement' if category_text == 'Maiden Statements'
      unless category_text.blank?
        category = make_slug(category_text) { |candidate_category| nil }
        if Debate::CATEGORIES.include?(category)
          self.url_category = category
        end
      end
    end

    def make_url_slug_text
      if name.include?("—") && (name =~ /^(Address in Reply)|(Offices of Parliament)/)
        major, minor = name.split("—")
        text = minor
      else
        text = String.new name.sub("—",' ')
      end
    end

end
