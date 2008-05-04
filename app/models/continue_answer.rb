class ContinueAnswer < Answer

  alias_method :original_is_answer?, :is_answer?

  def is_answer?
    false
  end

end
