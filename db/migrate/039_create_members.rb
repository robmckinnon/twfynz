class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.integer :person_id
      t.string :electorate
      t.integer :party_id
      t.date :from_date
      t.date :to_date
      t.string :from_what
      t.string :list_member_vacancy_url
      t.string :members_sworn_url
      t.string :maiden_statement_url
      t.string :to_what
      t.string :membership_change_url
      t.string :resignation_url
      t.string :valedictory_statement_url
      t.integer :replaced_by_id
      t.integer :term

      t.timestamps
    end

    left_parliament = {
        :jim_sutton=>['30 July 2006','http://theyworkforyou.co.nz/valedictory_statement/2006/jul/26',
            'http://theyworkforyou.co.nz/resignations/2006/aug/01/hon_jim_sutton_labour',
            :charles_chauvel, 'Labour'],
        :don_brash=>['6 February 2007','http://theyworkforyou.co.nz/valedictory_statement/2006/dec/12',
            'http://theyworkforyou.co.nz/resignations/2007/feb/13/dr_don_brash_nz_national',
            :katrina_shanks, "National"],
        :georgina_beyer=>['16 February 2007','http://theyworkforyou.co.nz/debate_on_prime_ministers_statement/2007/feb/14#labour_86',
            'http://theyworkforyou.co.nz/resignations/2007/feb/20/georgina_beyer_labour',
            :lesley_soper, 'Labour'],
        :ann_hartley=>['28 February 2008','http://theyworkforyou.co.nz/valedictory_statement/2008/feb/20',
            'http://theyworkforyou.co.nz/resignations/2008/mar/04/ann_hartley_labour',
            :louisa_wall, 'Labour'],
        :brian_donnelly=>['14 February 2008','http://theyworkforyou.co.nz/debate_on_prime_ministers_statement/2008/feb/13#nz_first_90',
            'http://theyworkforyou.co.nz/resignations/2008/feb/19/hon_brian_donnelly_nz_first',
            :dail_jones, "NZ First"],
        :dianne_yates=>['29 March 2008','http://theyworkforyou.co.nz/valedictory_statement/2008/mar/19',
            'http://theyworkforyou.co.nz/resignations/2008/apr/01/dianne_yates_nz_labour',
            :sua_william_sio, 'Labour']
    }

    joined_parliament = {
        :charles_chauvel=>['1 August 2006','http://theyworkforyou.co.nz/list_member_vacancy/2006/aug/01','http://theyworkforyou.co.nz/members_sworn/2006/aug/01','http://theyworkforyou.co.nz/maiden_statement/2006/aug/01'],
        :katrina_shanks=>['13 February 2007','http://theyworkforyou.co.nz/list_member_vacancy/2007/feb/13','http://theyworkforyou.co.nz/members_sworn/2007/feb/13','http://theyworkforyou.co.nz/maiden_statement/2007/feb/20'],
        :lesley_soper=>['20 February 2007','http://theyworkforyou.co.nz/list_member_vacancy/2007/feb/20','http://theyworkforyou.co.nz/members_sworn/2007/feb/20',nil],
        :louisa_wall=>['4 March 2008','http://theyworkforyou.co.nz/list_member_vacancy/2008/mar/04','http://theyworkforyou.co.nz/members_sworn/2008/mar/04','http://theyworkforyou.co.nz/maiden_statement/2008/mar/04'],
        :dail_jones=>['19 February 2008','http://theyworkforyou.co.nz/list_member_vacancy/2008/feb/19','http://theyworkforyou.co.nz/members_sworn/2008/feb/19',nil],
        :sua_william_sio=>['1 April 2008','http://theyworkforyou.co.nz/list_member_vacancy/2008/apr/01','http://theyworkforyou.co.nz/members_sworn/2008/apr/01','http://theyworkforyou.co.nz/maiden_statement/2008/apr/01']
    }

    left_party = {
        :taito_field=>['14 February 2007','Labour','http://theyworkforyou.co.nz/speakers_statements/2007/feb/14/parliamentary_labour_party_membership'],
        :gordon_copeland=>['16 May 2007','United Future','http://theyworkforyou.co.nz/speakers_statements/2007/may/16/gordon_copeland']
    }

    Mp.find(:all).each do |mp|
      id_name = mp.id_name.to_sym
      has_left = left_parliament.keys.include?(id_name)
      has_left_party = left_party.keys.include?(id_name)
      has_joined = joined_parliament.keys.include?(id_name)
      not_in_48th = (mp.former && !has_left)

      Member.create({
          :person_id => mp.id,
          :electorate => mp.electorate,
          :party_id => has_left_party ? Party.find_by_short(left_party[id_name][1]).id : (has_left ? Party.find_by_short(left_parliament[id_name][4]).id : mp.member_of_id),
          :from_date => not_in_48th ? nil : (has_joined ? Date.parse(joined_parliament[id_name][0]) : '2005-11-07'),
          :list_member_vacancy_url => has_joined ? joined_parliament[id_name][1] : nil,
          :members_sworn_url => not_in_48th ? nil : (has_joined ? joined_parliament[id_name][2] : 'http://theyworkforyou.co.nz/members_sworn/2005/nov/07'),
          :maiden_statement_url => has_joined ? joined_parliament[id_name][3] : nil,
          :to_date => has_left ? Date.parse(left_parliament[id_name][0]) : (has_left_party ? Date.parse(left_party[id_name][0]) : nil),
          :from_what => not_in_48th ? nil : 'General Election 2005',
          :to_what => has_left ? 'Resigned from Parliament' : (has_left_party ? 'Left party' : nil),
          :membership_change_url => has_left_party ? left_party[id_name][2] : nil,
          :resignation_url => has_left ? left_parliament[id_name][2] : nil,
          :valedictory_statement_url => has_left ? left_parliament[id_name][1] : nil,
          :term => (has_joined && joined_parliament[id_name][3]) ? 1 : 0,
          :replaced_by_id => has_left ? Mp.find_by_id_name(left_parliament[id_name][3].to_s).id : nil
      })

      if has_left_party
        Member.create({
            :person_id => mp.id,
            :electorate => mp.electorate,
            :party_id => Party.find_by_short('Independent').id,
            :from_date => Date.parse(left_party[id_name][0]),
            :to_date => nil,
            :from_what => 'Became an independent MP',
            :membership_change_url => left_party[id_name][2]
        })
      end
    end
  end

  def self.down
    drop_table :members
  end
end
