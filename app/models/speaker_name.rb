class SpeakerName

  attr_reader :name, :remaining

  @@name_to_anchor = {}

  class << self
    def reset_anchors
      @@name_to_anchor.clear
    end
  end

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

  def role
    if remaining
      if remaining.include?('—')
        parts = remaining.split('—')
        parts[0][/(Leader|Whip)/] ? parts[1] : parts[0]
      else
        remaining
      end
    else
      nil
    end
  end

  def anchor date
    case name
      when /^The /
        to_id(name).sub('the_','')
      when /^Madam SPEAKER$/i
        'madam_speaker'
      when /^Mr SPEAKER$/i
        'mr_speaker'
      when /SPEAKER-ELECT/
        'speaker-elect'
      when 'Mr DEPUTY SPEAKER'
        'deputy_speaker'
      else
        if remaining
          anchor = anchor_from_remaining
          if anchor == 'independent'
            mp = Mp.from_name(name, date)
            anchor = mp ? mp.anchor(date) : nil
          end
          @@name_to_anchor[name.downcase] = anchor
          anchor
        else
          anchor = @@name_to_anchor[name.downcase]
          unless anchor
            mp = Mp.from_name(name, date)
            anchor = mp.anchor(date) if mp
          end
          anchor
        end
    end
  end

  protected
    def to_id text
      text.to_latin.to_s.downcase.gsub(' ', '_')
    end

    def anchor_from_remaining
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
    end
end
