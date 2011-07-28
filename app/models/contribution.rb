require 'hpricot'

class Contribution < ActiveRecord::Base

  belongs_to :spoken_in, :class_name => 'Debate', :foreign_key => 'spoken_in_id'
  belongs_to :mp, :foreign_key => 'spoken_by_id'

  before_validation_on_create :populate_spoken_by_id
  before_validation :populate_date

  # acts_as_xapian :texts => [ :text ],
      # :values => [ [ :date, 0, "debate_date", :date ] ],
      # :terms => [ [ :date_int, 'D', "date" ] ]

  # acts_as_solr :fields => [:text]

  composed_of :speaker_name, :class_name => 'SpeakerName', :mapping => [ %w(speaker name) ]

  class << self

    def submodels
      models = [Answer, Clause, ClauseAlone, ClauseDescription, ClauseHeading,
      ClauseIndent1, ClauseIndent2, ClauseIndent3, ClauseModel, ClauseOutline,
      ClauseParagraph, ClausePart, ClauseSubClause, ClauseSubParagraph,
      ContinueAnswer, ContinueIntervention, ContinueQuestion, ContinueSpeech,
      Interjection, Intervention, Procedural, Question, Quotation,
      SectionHeader, Speech, SubsAnswer, SubsQuestion, SupAnswer, SupQuestion,
      Translation, VotePlaceholder]
    end

    def count_by_term term
      sql = 'SELECT COUNT(*) FROM contributions WHERE ' + create_condition(term)
      count_by_sql(sql)
      # search = ActsAsXapian::Search.new(submodels, term, :limit => 1)
      # return search.matches_estimated
    end

    def match_by_term term, limit, offset
      condition = create_condition(term)
      total_count = count_by_term(term)
      matches = find(:all, :conditions=> condition, :order=>'date DESC, spoken_in_id DESC',
          :limit => limit,
          :offset => offset)
      return matches, total_count
      # search = ActsAsXapian::Search.new(submodels, term,
          # :limit => limit,
          # :offset => offset,
          # :sort_by_prefix => 'debate_date')
      # return search.results.collect{|h| h[:model]}, search.matches_estimated
    end

    def search_by_term term
      condition = create_condition(term)
      sql = 'SELECT * FROM contributions WHERE ' + condition
      sql += ' ORDER BY spoken_in_id DESC, ' + condition + ' DESC'

      contributions = find_by_sql(sql).uniq
      debates = Debate.remove_duplicates contributions.collect {|c| c.debate}
      contributions.select{|c| debates.include?(c.debate) }
    end

    def find_by_mp mp_id, limit
      find(:all,
          :conditions => [ "spoken_by_id = ?", mp_id],
          :order => "id DESC",
          :limit => limit)
    end

    # For a list of contributions returns first contribution from
    # recent debates sorted by date.
    def recent_contributions contributions, spoken_by_id, spoken_by_type
      debates = contributions.collect {|o| o.debate}.uniq.compact.sort { |a,b| b.date <=> a.date }
      debates = Debate::remove_duplicates debates
      debates = debates[0..4] if debates.size > 5

      recent_contributions = debates.collect do |d|
        if spoken_by_type == Mp
          by_mp = d.contributions.select {|c| c.spoken_by_id == spoken_by_id }
          non_interjections = by_mp.select {|c| !c.is_a?(Interjection) }
          non_interjections.empty? ? by_mp.first : non_interjections.first
        elsif spoken_by_type == Party
          speech = d.contributions.select {|o| o.mp and o.mp.party.id == spoken_by_id and (o.is_speech? or o.is_answer? or o.is_question?) }.first
          speech = d.contributions.select {|o| contributions.include? o }.first unless speech
          speech
        end
      end
      recent_contributions.sort { |a,b| a.debate.date <=> b.debate.date }.reverse
    end

    def all_subclasses
      Dir.glob( RAILS_ROOT + '/app/models/*.rb' ) do |file_name|
        load file_name if /.rb$/ =~ file_name
      end
      ObjectSpace.subclasses_of( Contribution )
    end

    def find_with_solr term
      multi_solr_search term, :models => all_subclasses, :results_format => :objects
    end

    def group_by_about_and_debate contributions
      contributions       = contributions.uniq.sort_by { |c| c.debate.about ? c.debate.about.id : c.debate.id }
      contribution_groups = contributions.in_groups_by { |c| c.debate.about ? c.debate.about.id : c.debate.id }

      contribution_groups.each_with_index do |group,index|
        contribution_groups[index] = group.sort_by { |c| c.debate.id }.in_groups_by{ |c| c.debate.id }
      end

      contribution_groups.each do |group|
        group.sort! { |a, b| b.first.debate.date <=> a.first.debate.date }
        group.each { |set| set.sort!{ |a,b| a.id <=> b.id } }
      end

      contribution_groups.sort! { |a,b| b.last.last.debate.date <=> a.last.last.debate.date }
      contribution_groups
    end

    def find_mentions search_names
      contributions = search_names.inject([]) { |contributions, name| contributions + search_name(name) }
      group_by_about_and_debate contributions
    end

    def search_name name
      term = name.gsub('"','')
      term = '"' + term + '"' if term.include?(' ')
      contributions = search_by_term(term)
      definitely_maori = name.contains_macrons?

      bank_of_nz = name == 'Bank of New Zealand'
      contributions.select do |c|
        if definitely_maori
          c.text.include? name
        elsif bank_of_nz
          c.text.gsub('Reserve Bank of New Zealand','').include? name
        else
          c.text.to_latin.to_s.include? name
        end
      end
    end
  end

  def wordle_text
    text ? text.gsub(/<[^<]+>/,' ').squeeze(' ').strip : ''
  end

  def first_sentence
    sentence = /[^;^\.^\?]+(;|\.|\?)/
    case text
      when sentence
        first = text[sentence].gsub(/<[^>]+>/,'')
        if first[/I raise a point of order, M(adam|r) Speaker./]
          second = text.sub(first+' ','')[sentence]
          second ? second.gsub(/<[^>]+>/,'') : first
        else
          first
        end
      else
        nil
    end
  end

  def debate
    debate = spoken_in
  end

  def anchor_prefix
    speaker ? speaker_name.anchor(debate.date) : nil
  end

  def prefixed_anchor
    anchor_prefix ? anchor_prefix+'_'+anchor : anchor
  end

  def anchor
    @anchor_index = debate.contribution_id(self).to_s unless @anchor_index
    @anchor_index
  end

  def anchor_in_debate the_debate
    @anchor_index = the_debate.contribution_id(self).to_s unless @anchor_index
    @anchor_index
  end

  def css_class
    self.class.to_s.downcase
  end

  def html
    html = text.gsub('&quote;','"')
    index = 'a'
    new_line = "\n"

    html = "<p>#{html}</p>" unless html.include?('<p>')
    paragraphs = html.split('<p').select {|p| p.strip.length > 0}

    text = paragraphs.inject([]) do |result, p|
      result << new_line unless index == 'a'
      result << '<p'
      result << %Q[ id='#{anchor()}#{index}'] if paragraphs.size > 1
      result << p
      index.next!
      result
    end.join('')

    text.gsub!(/<\/em>([A-Za-z0-9])/, '</em> \1')
    text
  end

  def has_speaker?
    (speaker and speaker.size > 0)
  end

  def is_speech?
    false
  end

  def include? phrase
    if phrase.is_a? String
      text && text.include?(phrase)
    else
      text && text[phrase]
    end
  end

  def starts_with? phrase
    text && text.starts_with?("<p>#{phrase}")
  end

  def is_point_of_order?
    starts_with?('I raise a point of order')
  end

  def is_motion?
    starts_with?('I move that')
  end

  def is_motion_to_now_read?
    text.include?('I move') && text.include?('be now read')
  end

  def bill_names
    Bill.bill_names text.match(/That the (.*)be now read/)[1]
  end

  def is_interjection?
    false
  end

  def is_question?
    false
  end

  def is_answer?
    false
  end

  def is_vote?
    false
  end

  def is_procedural?
    false
  end

  def previous_in_debate
    if id
      if (id != 1)
        prior = Contribution.find(id - 1)
        if prior.spoken_in_id == spoken_in_id
          prior
        else
          nil
        end
      else
        nil
      end
    elsif spoken_in
      index = spoken_in.contributions.index(self)
      if index && index != 0
        spoken_in.contributions[index - 1]
      else
        nil
      end
    else
      nil
    end
  end

  def geonames
    if text
      xml = '<wrapper>' + text + '</wrapper>'
      doc = Hpricot.XML xml
      geoname_matches = handle_contribution_part doc.children.first, []
      geoname_matches.collect {|geoname_match| geoname_match[1]}
    else
      []
    end
  end

  # protected

    def handle_contribution_part node, geoname_matches
      if node.children
        node.children.each do |child|
          if child.text?
            text = child.to_s
            geoname_matches += Geoname.matches(text) unless text.empty?
          elsif child.elem?
            geoname_matches = handle_contribution_part(child, geoname_matches)
          end
        end
      end
      geoname_matches
    end

    def self.create_condition term
      if term[/^"([\S]+)"$/]
        term = term[/^"([\S]+)"$/, 1]
      end
      term = term.gsub('\\', '').gsub(';','').gsub('>','').gsub('<','').gsub("'",'').gsub('*','').gsub('%','')
      terms = term.split

      condition = 'MATCH (text) AGAINST '
      if terms.length == 1
        condition + %Q[("#{term}")]
      elsif term.include? '"'
        condition + %Q[('#{term}' IN BOOLEAN MODE)]
      else
        condition + %Q[("+#{terms.join(" +")}" IN BOOLEAN MODE)]
      end
    end

    # Override if needed
    def party_makes_sense? mp, date
      true
    end

    def populate_date
      self.date = spoken_in.date if spoken_in
      self.date_int = spoken_in.date.to_s.tr('-','').to_i if spoken_in
    end

    def populate_spoken_by_id
      ignore_lack_of_speaker = (spoken_in && spoken_in.name == 'Commission Opening of Parliament')
      return if ignore_lack_of_speaker

      raise "Validation failed: :speaker can't be blank for #{type}: #{text}" if speaker.blank?

      if spoken_by_id.blank?
        self.speaker = speaker.chomp(':').chomp('“').chomp(',').chomp('.').strip.sub(/(\S)\(/,'\1 (').sub('Madsam SPEAKER','Madam SPEAKER')
        case speaker.downcase
          when 'hon members', 'hon member', 'the chairperson'
            # ignore populating spoken_by_id
          else
            populate_spoken_by_id_from_mp speaker
        end
      end
    end

    def populate_spoken_by_id_from_mp speaker
      populate_date # to ensure date is set
      if mp = Mp.from_name(speaker, date)
        if party_makes_sense?(mp, date)
          self.spoken_by_id = mp.id
        else
          raise "Validation failed: #{mp.last}, #{mp.party.short} shouldn't be making #{self.class.name} in #{debate.name}"
        end
      else
        raise 'Validation failed: cannot find member from speaker name: ' + speaker
      end
    end
end
