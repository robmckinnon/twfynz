class SpeakerName

  attr_reader :name, :remaining

  def initialize(name)
    name = name.split ' ('
    @name = name[0]
    @remaining = if name[1]
                   name[1..(name.size-1)].join(' (')
                 else
                   nil
                 end
    @remaining.chomp!(')') if @remaining
  end

  def anchor
    if name[/^The /]
      to_id(name).sub('the_','')

    elsif remaining
      case remaining
        when /^(Deputy )?Leader of the House/
          to_id remaining
        when 'Leader of the Opposition'
          'national'
        when /^(Member|Minister) in charge/i
          "#{to_id $1}_in_charge"
        when /^(Leader|Co-Leader|Deputy Leader|Senior Whip|Junior Whip|Whip|Musterer)—(.*)/
          "#{to_id $2}"
        when /^(.*) responsible/, /^(.*) in/, /^(.*) [of|for]/, /^(.*)—/
          to_id $1
        else
          remaining.downcase.gsub(' ','_')
      end
    else
      nil
    end
  end

  protected
    def to_id text
      text.to_latin.to_s.downcase.gsub(' ', '_')
    end

end
