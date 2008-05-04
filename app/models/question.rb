class Question < Contribution

  alias_method :original_is_question?, :is_question?

  def is_question?
    true
  end
end
