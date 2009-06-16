require "#{RAILS_ROOT}/config/initializers/geoname_config"

# Configuration is in: config/initializers/geoname_config.rb
class Geoname < ActiveRecord::Base

  acts_as_slugged

  before_create :clean_data, :create_slug
  before_save :populate_count_of_mentions

  def clean_data
    name.each do |word|
      if (match = /[A-Z]+/.match(word))
        if match[0] == word
          self.name.sub!(word, word.capitalize)
          self.asciiname.sub!(word, word.capitalize)
        end
      end
    end
  end

  def create_slug
    self.slug = make_slug(name.to_latin) do |candidate_slug|
      duplicate_found = Geoname.find_all_by_slug(candidate_slug).size > 0
      duplicate_found
    end
  end

  def Geoname.find_all_places
    Geoname.find(:all).select{|g| (!g.ignore) && (g.count_of_mentions > 0) }.sort_by(&:count_of_mentions).reverse
  end

  def Geoname.find_all_names
    Geoname.find_by_sql('select name,geonameid,feature_code from geonames')
  end

  LOOKUPS = {}

  def find_mentions
    contributions = Contribution::search_name(name)
    contributions = contributions.select {|c| Geoname.matches(c.text.to_latin, self).size > 0 }
    if contributions
      Contribution::group_by_about_and_debate contributions
    else
      []
    end
  end

  def Geoname.lookup_by_first_word_in_name word
    if LOOKUPS.has_key? word
      LOOKUPS[word]
    else
      geoname = Geoname.find_all_by_first_word_in_name(word)
      LOOKUPS[word] = geoname
      geoname
    end
  end

  def Geoname.matches text, restrict_to=nil
    text = text.gsub('>',' ').gsub('</', '  ')
    tokenizer = WordTokenizer.new(text, GEONAME_STOP_WORDS)

    geonames_to_locations = []
    tokenizer.capitalized_words.each do |word_location|
      word = unpunctuate(word_location[1])
      if restrict_to
        if restrict_to.first_word_in_name == word
          geonames_to_locations << [[restrict_to], word_location]
        end
      else
        geonames_to_locations << [Geoname.lookup_by_first_word_in_name(word), word_location]
      end
    end

    matches = []
    geonames_to_locations.each do |geoname_to_location|
      geonames = geoname_to_location[0]
      offset = geoname_to_location[1][0]

      geonames.each do |geoname|
        if (offset == text.index(geoname.name, offset))
          if !inside_previous_name(matches, offset, geoname)
            matches << [offset, geoname] unless IGNORE_GEONAMES.include? geoname.name
          end
        end
      end
    end

    matches = delete_broken_matches(text, matches) if matches.size > 0
    matches
  end

  def self.delete_broken_matches text, matches
    tokenizer = WordTokenizer.new(text, GEONAME_STOP_WORDS)
    to_delete = []
    location_of_matches_hash = {}

    matches.each do |match|
      match_index = match[0]
      if location_of_matches_hash.has_key? match_index
        other_match = location_of_matches_hash[match_index]
        to_delete << other_match unless to_delete.include?(other_match)
        to_delete << match
      else
        location_of_matches_hash[match_index] = match
        match_first_name = match[1].first_word_in_name

        begin
          word_at_match_index = tokenizer.word_at_character_index(match_index)
        rescue Exception => e
          raise e.to_s + ' *** ' + match_index.to_s + ' *** ' + match_first_name + ' *** ' + tokenizer.to_yaml
        end

        previous_word = unpunctuate(tokenizer.word_previous_to_word_at(match_index))
        if previous_word
          unless NON_GEONAME_MATCH_TRIGGERS.include?(previous_word)
            # logger.warn '*****************************'
            # logger.warn previous_word + ' ' + unpunctuate(word_at_match_index)
            # logger.warn '*****************************'
          end
        end
        next_word = unpunctuate(tokenizer.word_following_word_at_index(match_index))
        if next_word
          unless NON_GEONAME_MATCH_TRIGGER_SUFFIX.include?(next_word)
            # logger.warn '*****************************'
            # logger.warn  unpunctuate(word_at_match_index) + ' ' + next_word
            # logger.warn '*****************************'
          end
        end
        if ( match_first_name != unpunctuate(word_at_match_index) ||
            NON_GEONAME_MATCH_TRIGGERS.include?(previous_word) ||
            (previous_word && FIRST_NAMES.include?(previous_word.upcase)) ||
            NON_GEONAME_MATCH_TRIGGERS.include?(unpunctuate(tokenizer.word_preceding_previous_to_word_at(match_index))) )
          to_delete << match
        elsif (tokenizer.word_preceding_preceding_previous_to_word_at(match_index) == 'Lord' &&
          tokenizer.word_previous_to_word_at(match_index) == 'of')
          to_delete << match

        elsif NON_GEONAME_MATCH_TRIGGER_SUFFIX.include? next_word
          to_delete << match
        end
      end
    end
    to_delete.each do |match|
      matches.delete(match)
    end
    logger.warn '*****************************'
    logger.warn matches.collect {|m| m[0].to_s + ' ' + m[1].name}.to_yaml
    logger.warn '*****************************'
    matches
  end

  def Geoname::format_geonames text
    geoname_matches = Geoname.matches text
    geoname_matches.each do |geoname_match|
      index = geoname_match[0]
      geoname = geoname_match[1]
      name = geoname.name
      if index > 0
        start = text.to(index - 1)
      else
        start = ''
      end

      if text.length > (index + name.length)
        finish = text.from(index + name.length)
      else
        finish = ''
      end

      geo_microformatted = geoname.microformatted
      index_delta = geo_microformatted.length - name.length
      geoname_matches.each do |a_geoname_match|
        a_geoname_match[0] = a_geoname_match[0] + index_delta
      end
      text = start + geo_microformatted + finish
    end
    text
  end

  def ignore
    IGNORE_GEONAMES.include?(name) || SUPPRESS_GEONAMEIDS.include?(geonameid)
  end

  def microformatted
    %Q[<span class="geo">#{name}<span class="space"> </span><span class="latitude">#{latitude}</span><span class="space"> </span><span class="longitude">#{longitude}</span></span>]
  end

  def Geoname.unpunctuate text
    WordTokenizer.unpunctuate text
  end

  def populate_count_of_mentions
    self.count_of_mentions = live_count_of_debates_mentioned_in
  end

  def live_count_of_debates_mentioned_in
    find_mentions.inject(0) {|sum,group| sum + group.size}
  end

  private

    def self.inside_previous_name matches, offset, geoname
      inside = false
      if matches.last and (matches.last[1].name != geoname.name)
        last_offset = matches.last[0]
        length = matches.last[1].name.size
        if offset < (last_offset + length)
          inside = true
        end
      end
      inside
    end

end
