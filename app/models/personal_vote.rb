class PersonalVote < Vote

  def ayes_cast
    get_cast ayes, ayes_teller
  end

  def noes_cast
    get_cast noes, noes_teller
  end

  def ayes_teller
    ayes.last
  end

  def noes_teller
    noes.last
  end

  private

    def get_cast votes_cast, teller
      cast = Array.new votes_cast
      cast.delete(teller)
      cast.sort! do |vote_cast, other_cast|
        mp = vote_cast.mp
        other = other_cast.mp
        comp = mp.last <=> other.last
        if comp == 0
          comp = mp.first <=> other.first
        end
        comp
      end

      rows = (votes_cast.size + 6) / 4

      remaining = cast.reverse

      column1 = []
      0.upto(rows - 1) {|i| column1 << remaining.pop }
      column2 = []
      0.upto(rows - 1) {|i| column2 << remaining.pop }
      column3 = []
      0.upto(rows - 1) {|i| column3 << remaining.pop }
      column4 = []
      0.upto(rows - 1) {|i| column4 << remaining.pop }

      column4[rows - 1] = teller
      column4[rows - 2] = 'Teller:'

      columns = []
      0.upto(rows - 1) do |i|
        columns << column1[i]
        columns << column2[i]
        columns << column3[i]
        columns << column4[i]
      end
      columns
    end

end
