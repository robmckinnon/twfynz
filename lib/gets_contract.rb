require 'morph'

class GetsContract
  include Morph

  def initialize id
    doc = Hpricot open("http://www.gets.govt.nz/Default.aspx?show=AwardedDetail&AwardedID=#{id}")

    (doc/'span.data').collect do |datum|
      label = datum.at('..').previous_sibling.inner_text
      label = label.gsub('$','').gsub('?',' ').gsub("\t",' ').gsub("\n",' ').gsub("\r",' ').strip.squeeze(' ')
      value = datum.inner_text.to_s

      self.morph(label, value)
    end
  end
end
