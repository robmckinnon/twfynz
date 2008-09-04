class Minister < ActiveRecord::Base

  belongs_to :portfolio, :foreign_key => 'responsible_for_id'

  class << self
    def from_name name
      name = name.sub('Acting ', '').strip.downcase.to_latin.gsub('’',"'")
      find(:all).select {|m| m.title.downcase == name}.first
    end

    def all_minister_titles
      @all_minister_titles = all.collect(&:title).sort unless @all_minister_titles
      @all_minister_titles
    end
  end
end
