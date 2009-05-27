# == Schema Information
# Schema version: 21
#
# Table name: pecuniary_categories
#
#  id        :integer(11)   not null, primary key
#  snapshot  :boolean(1)    not null
#  from_date :date          not null
#  to_date   :date          not null
#  name      :string(72)    default(""), not null
#

class PecuniaryCategory < ActiveRecord::Base

  has_many :pecuniary_interests

  class << self
    def load_register
      last_category = nil
      last_mp = nil
      last_item = nil

      lines = []
      File.open(RAILS_ROOT+'/data/register.txt').each_line do |line|
        if line.blank? || line[/^\d+$/] || line[/REGISTER OF PECUNIARY INTERESTS/]
          # ignore
        elsif mp = Mp.from_name(line, Date.new(2008,1,1) )
          lines << line
        elsif line[/^(\d+) (.+)$/]
          lines << line
        elsif line[/^[A-Z].+$/]
          lines << line
        elsif !line.blank?
          x = lines.pop
          x += line
          lines << line
        end
      end

      lines.each do |line|
        if mp = Mp.from_name(line, Date.new(2008,1,31) )
          last_mp = mp
        elsif line[/^(\d+) (.+)$/]
          last_category = PecuniaryCategory.find($1.to_i)
          if false
            if PecuniaryCategory.exists?($1.to_i)
              last_category = PecuniaryCategory.find($1.to_i)
              if last_category.name != $2
                last_category.name = $2
                last_category.save!
              end
            else
              category = PecuniaryCategory.new :name => $2, :snapshot => false, :to_date => '2008-01-31', :from_date => '2007-01-31'
              category.save!
              category.id = $1.to_i
              category.save!
              last_category = category
            end
          end
        elsif line[/^[A-Z].+$/]
          PecuniaryInterest.find_or_create_by_mp_id_and_pecuniary_category_id_and_item(last_mp.id, last_category.id, line.strip)
        else
          puts line
        end
      end
    end
  end
end
