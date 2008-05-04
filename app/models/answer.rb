class Answer < Contribution

  alias_method :original_is_answer?, :is_answer?

  def is_answer?
    true
  end

  def party_makes_sense? mp
    if mp.party
      party = mp.party.short
      if debate.about && debate.about.is_a?(Portfolio) &&
          (party == 'National' || party == 'Green' || party == 'Maori Party' || party == 'ACT')
        false
      else
        true
      end
    else
      true
    end
  end

end
