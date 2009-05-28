class String

  def to_latin
    self.mb_chars.
      gsub('Ā','A').gsub('Ē','E').gsub('Ī','I').gsub('Ō','O').gsub('Ū','U').
      gsub('ā','a').gsub('ē','e').gsub('ī','i').gsub('ō','o').gsub('ū','u')
  end

  def contains_macrons?
    include?('Ā') ||
        include?('Ē') ||
        include?('Ī') ||
        include?('Ō') ||
        include?('Ū') ||
        include?('ā') ||
        include?('ē') ||
        include?('ī') ||
        include?('ō') ||
        include?('ū')
  end
end