class DebateAlone < Debate

  belongs_to :about, :polymorphic => true

  def full_name
    name
  end

  def category
    'debate'
  end

  def next_index
    index.next
  end

  protected
    def find_by_candidate_slug candidate_slug
      DebateAlone.find_by_url_slug_and_date_and_publication_status(candidate_slug, date, publication_status)
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
