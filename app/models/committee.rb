class Committee < ActiveRecord::Base

  has_many :committee_chairs
  has_many :submission_dates
  has_many :submissions
  has_many :sub_debates, :as => :about
  has_many :debate_alones, :as => :about
  has_many :bills, :foreign_key => 'referred_to_committee_id'

  before_validation_on_create :default_former

  class << self
    def from_name name
      name = name.gsub(' Committee', '').sub('Māori','Maori').strip
      find(:all).select do |c|
        committee = c.committee_name
        committee == name || committee.to_latin == name
      end.first
    end

    def all_committee_names
      @all_committee_names = all.collect(&:full_committee_name).sort.collect{|name| name.sub('Maori','Māori')} unless @all_committee_names
      @all_committee_names
    end
  end

  def full_name
    self.committee_name
  end

  def full_committee_name
    committee_name + ' Committee'
  end

  def bills_before_committee
    bills.select {|b| b.current? and (not(b.sc_reports) or (b.sc_reports > Date::today)) }
  end

  def reported_bills_current
    bills.select {|b| b.current? and (b.sc_reports and b.sc_reports < Date::today) }
  end

  def reported_bills_negatived
    bills.select {|b| b.negatived? }
  end

  def reported_bills_assented
    bills.select {|b| b.assented? }
  end

  def reported_bills
    bills.select {|b| b.sc_reports and b.sc_reports < Date::today }
  end

  protected

    def default_former
      self.former = 0 unless self.former
    end

end
