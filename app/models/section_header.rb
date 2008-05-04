class SectionHeader < Contribution

  alias_method :original_populate_spoken_by_id, :populate_spoken_by_id

  def is_procedural?
    true
  end

  protected

    def populate_spoken_by_id
      # do nothing, as section header has no speaker
    end

end
