class Answer < Contribution

  alias_method :original_is_answer?, :is_answer?

  def is_answer?
    true
  end

  def party_makes_sense? mp, date
    if mp.party
      party = mp.party.short
      if debate.about && debate.about.is_a?(Portfolio)

        if Parliament.date_within?(48, date) && (party == 'National' || party == 'Green' || party == 'Maori Party' || party == 'ACT')
          false
        elsif Parliament.date_within?(49, date) && (party == 'Labour' || party == 'Green'  || party == 'Progressive')
          false
        else
          true
        end
      else
        true
      end
    else
      true
    end
  end

end
