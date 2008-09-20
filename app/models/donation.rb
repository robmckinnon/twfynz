class Donation < ActiveRecord::Base

  belongs_to :party
  belongs_to :organisation

  before_validation_on_create :populate_party

  class << self
    def per_page
      50
    end
  end

  attr_accessor :is_from_organisation

  def organisation_slug
    @organisation_slug ? @organisation_slug : '______'
  end

  protected
    def populate_party
      if party_name
        mappings = {
            'ACT NZ' => 'ACT',
            'ACT New Zealand' => 'ACT',
            'Aotearoa Legalise Cannabis Party' => '',
            'Christian Coalition' => '',
            'Christian Heritage' => '',
            'Destiny New Zealand' => '',
            'Direct Democracy Party' => '',
            'Green Party' => 'Green',
            'Green Party of Aotearoa NZ' => 'Green',
            'Jim Anderton\'s Progressive Coalition' => 'Progressive',
            'Jim Anderton\'s Progressive Party' => 'Progressive',
            'Libertarianz' => '',
            'Maori Party' => 'Maori Party',
            'NZ Democratic Party' => '',
            'NZ Democratic Party Inc' => '',
            'NZ First Party' => 'NZ First',
            'NZ Labour Party' => 'Labour',
            'NZ National Party' => 'National',
            'Natural Law Party' => '',
            'New Zealand First' => 'NZ First',
            'New Zealand First Party' => 'NZ First',
            'New Zealand Labour Party' => 'Labour',
            'New Zealand National Party' => 'National',
            'Progressive Green Party' => '',
            'Progressive Party' => 'Progressive',
            'Republic of New Zealand Party' => '',
            'Te Tawharau Party' => '',
            'The Alliance' => '',
            'The Alliance Party' => '',
            'The Family Party' => '',
            'The Green Party of Aotearoa/New Zealand' => 'Green',
            'The Greens, The Green Party of Aotearoa' => 'Green',
            'The Greens, The Green Party of Aotearoa NZ' => 'Green',
            'The Greens, The Green Party of Aotearoa NZ Inc' => 'Green',
            'The Greens, The Green Party of Aotearoa New Zealand' => 'Green',
            'The New Zealand Democratic Party Inc' => '',
            'The New Zealand Democratic Party for Social Credit' => '',
            'The New Zealand Democrats for social credit' => '',
            'The New Zealand National Party' => 'National',
            'UNITED FUTURE NEW ZEALAND' => 'United Future',
            'United Future New Zealand' => 'United Future' }
        short_name = mappings[party_name]
        unless short_name.blank?
          party = Party.find_by_short short_name
          if party
            self.party_id = party.id
          end
        end
      end
    end
end
