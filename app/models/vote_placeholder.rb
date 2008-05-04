class VotePlaceholder < Contribution

  before_destroy :destroy_vote
  belongs_to :vote

  alias_method :original_is_vote?, :is_vote?
  alias_method :original_populate_spoken_by_id, :populate_spoken_by_id

  def is_vote?
    true
  end

  def debate
    spoken_in
  end

  protected

    def populate_spoken_by_id
      # do nothing, as vote placeholder has no speaker
    end

    def destroy_vote
      if vote
        vote.destroy
      end
    end

end
