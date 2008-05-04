class Quotation < Contribution

  alias_method :original_populate_spoken_by_id, :populate_spoken_by_id

  protected

    def populate_spoken_by_id
      # do nothing, as quotation has no speaker
    end

end
