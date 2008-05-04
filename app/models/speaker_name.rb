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

end
