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
end
