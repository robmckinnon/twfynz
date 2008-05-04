class Procedural < Contribution

  alias_method :original_is_procedural?, :is_procedural?
  alias_method :original_populate_spoken_by_id, :populate_spoken_by_id

  def is_procedural?
    true
  end

  protected

    def populate_spoken_by_id
      # do nothing, as procedural contribution has no speaker
    end

end
