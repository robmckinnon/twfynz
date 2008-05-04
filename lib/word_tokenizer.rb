class WordTokenizer

  attr_reader :words

  def initialize text, stop_words=[]
    @stop_words = stop_words
    @text = text
    @words = []
    offset = 0
    @text.gsub('—',' ').split.each do |word|
      index = @text.index(word, offset)
      offset = index + word.length
      @words << [index, word]
    end
  end

  def word_at_character_index index
    word = nil
    while word == nil
      word = @words.assoc(index)
      index = index - 1
    end
    word[1]
  end

  def capitalized_words
    @words.select do |word|
      if @stop_words.include?(WordTokenizer.unpunctuate(word[1]))
        false
      elsif (match = /([^A-Z]*)([A-Z]..+)/.match(word[1]))
        potential_word = match[2]
        if @stop_words.include?(WordTokenizer.unpunctuate(potential_word))
          false
        else
          word[1] = potential_word
          if match[1].size > 0
            offset = match[1].size
            word[0] += offset
          end
          true
        end
      else
        false
      end
    end.each { |word| word[1] = WordTokenizer.unpunctuate(word[1]) }
  end

  def word_following_word_at_index index
    order_index = word_order_index(index)
    next_index = order_index + 1

    if order_index && next_index < @words.size
      @words[next_index][1].chomp('.')
    else
      nil
    end
  end

  def word_previous_to_word_at index
    order_index = word_order_index(index)
    if order_index && order_index > 0
      @words[order_index - 1][1].chomp('.')
    else
      nil
    end
  end

  def word_preceding_previous_to_word_at index
    order_index = word_order_index(index)
    if order_index && order_index > 1
      @words[order_index - 2][1].chomp('.')
    else
      nil
    end
  end

  def word_preceding_preceding_previous_to_word_at index
    order_index = word_order_index(index)
    if order_index && order_index > 2
      @words[order_index - 3][1].chomp('.')
    else
      nil
    end
  end

  def word_order_index index
    word = word_at_character_index(index)
    @words.index(@words.rassoc(word))
  end

  def to_yaml
    words.collect{|w| w << words.index(w)}.to_yaml
  end

  def WordTokenizer.unpunctuate text
    if text
      text.tr("().,:;?!*'’",'')
    else
      nil
    end
  end
end
