class VoteCast < ActiveRecord::Base

  belongs_to :vote
  belongs_to :mp
  belongs_to :party

  before_validation_on_create :populate_party, :populate_mp,
    :default_present, :default_teller

  def date= date
    @date=date
  end

  def date
    @date ? @date : vote.debate.date
  end

  protected

    def mp_name= name
      @mp_name = name
    end

    def party_name= name
      @party_name = name
    end

    def populate_party
      if @party_name
        party = Party.from_vote_name(@party_name)
        raise 'cannot find party from vote_name ' + @party_name unless party
        self.party_id = party.id
        @party_name = nil
      end
    end

    def populate_mp
      if @mp_name
        mp = Mp.from_vote_name(@mp_name.chomp(','), date, party)
        self.mp_id = mp.id
        @mp_name = nil
      end
    end

    def default_present
      self.present = 0 unless self.present
    end

    def default_teller
      self.teller = 0 unless self.teller
    end
end
