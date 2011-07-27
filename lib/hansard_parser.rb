# coding:utf-8
require 'rubygems'
require 'open-uri'
require 'hpricot'

class HansardParser

  class << self
    def load_file file
      open(file).read
    end
    def load_doc file
      text = load_file file
      text.gsub!(/<caption>[^<]*<p>/,'<caption>')
      text.gsub!(/<\/p>[^<]*<\/caption>/,'</caption>')
      text.gsub!(%Q|<p class="a">\n        <strong>Prayers</strong>.</p>|, '')
      text.gsub!(%Q|<p class="a">\n        <strong>Karakia</strong>.</p>|, '')
      Hpricot text
    end
  end

  def initialize file, url, date
    @parliament_url = url
    @file = file
    @speaker_recalled = false
    @debate_date = date
  end

  def parse_oral_answer debate_index, oral_answers=nil
    answer = parse debate_index + 1
    unless oral_answers
      oral_answers = OralAnswers.new({
        :name => 'Questions for Oral Answer',
        :date => answer.date,
        :publication_status => answer.publication_status,
        :debate_index => 1,
        :source_url => answer.source_url,
        :css_class => 'qoa',
        :hansard_volume => answer.hansard_volume,
        :start_page => answer.start_page
      })
    end
    oral_answers.add_oral_answer(answer)
    oral_answers
  end

  def parse debate_index=1
    @doc ? @doc : (@doc = HansardParser.load_doc(@file))
    type = @doc.at('.copy/.section[1]/div[1]')['class']

    document_reference = @doc.at('.copy/.section[1]/p[1]').inner_html
    if (document_reference.include?('Volume:') and document_reference.include?('Page:'))
      split = document_reference.split(';')
      @hansard_volume = split[0].split(':').last.to_i
      @page = split[1].split(':').last.chomp(']').to_i
    end

    @title_is_h2 = true

    if type == 'QOA'
      create_oral_answers debate_index

    elsif type == 'SubsQuestion'
      create_oral_answer document_title, (@doc/'.copy/.section[1]/.SubsQuestion[1]')[0], true, debate_index

    elsif type == 'BillDebate'
      create_bill_debate debate_index

    elsif type == 'BillDebate2'
      create_bill_debate_from_bill_debate2 debate_index

    elsif type == 'BillDebateMid'
      create_bill_debate_from_bill_debate_mid debate_index

    elsif type == 'DebateAlone'
      create_debate_alone debate_index

    elsif type == 'Debate'
      create_debate debate_index, 'Debate'

    elsif type == 'DebateDebate'
      name = (((@doc/'.DebateDebate/h2').first) / 'text()')[0].to_clean_s
      if name.ends_with?('Bill')
        create_bill_debate_from_debate_debate debate_index
      else
        create_debate debate_index, 'DebateDebate'
        # raise 'cannot create debate, unrecognized type: ' + type
      end
    else
      raise 'cannot create debate, unrecognized type: ' + type
    end
  end

  protected

    def get_date
      yyyy_mm_dd = (@doc/'meta[@name="DC.Date"]')[0]['content']
      year = yyyy_mm_dd[0..3].to_i
      month = yyyy_mm_dd[5..6].to_i
      day = yyyy_mm_dd[8..9].to_i
      dc_date = Date.new(year, month, day)
      puts "dc_date different from file_date: #{dc_date}; #{@debate_date}" if dc_date != @debate_date

      @debate_date # use debate date from file name
    end

    def publication_status
      status = (@doc/'.copy/.section[1]/p[1]/text()')[0].to_s
      if status.include? 'Advance'
        'A'
      elsif status.include? 'Uncorrected'
        'U'
      elsif (match = /Volume:\d+;Page:\d+/.match status)
        'F'
      else
        raise 'publication status not found'
      end
    end

    def create_oral_answers debate_index
      qoa = (@doc/'.QOA')[0]
      no_questions = false
      if qoa.inner_text[/no questions have been lodged today/]
        name = 'Questions for Oral Answer'
        no_questions = true
      else
        name = (qoa/'h2[1]/text()')[0].to_clean_s
        if is_date?(name)
          name = (qoa/'h2[2]/text()')[0].to_clean_s
        end
      end

      answers_array = []
      answers = OralAnswers.new({
        :name => name,
        :date => get_date,
        :publication_status => publication_status,
        :debate_index => debate_index,
        :source_url => @parliament_url,
        :css_class => 'qoa',
        :hansard_volume => @hansard_volume,
        :start_page => @page
      })

      answers_array << answers

      hit_first_question = false

      qoa.children.each_with_index do |node, index|
        if node.text?
          text = node.to_clean_s
          unless (text.blank?)
            raise 'unexpected text near oral answer: ' + text
          end
        elsif node.elem?
          if (node.name == 'h4' or
              (node.name == 'h2' and (re_question = node.at('text()').to_clean_s.starts_with?('Question No')) ) )
            type = node['class']
            if (type == 'QSubjectHeading' or type == 'QSubjectheadingalone' or re_question)
              hit_first_question = true
              debate_index = debate_index.next
              answer_name = node.to_plain_text.to_clean_s
              answer = create_oral_answer answer_name, node.next_sibling, false, debate_index
              answers.add_oral_answer answer
            else
              raise 'unexpected type of h4 class under QOA: ' + type
            end
          elsif node.name == 'h2'
            heading = node.inner_html.to_clean_s
            if (heading == name or is_date?(heading))
                #ignore
            elsif (heading == 'Questions to Members' or
                heading == 'Urgent Questions' or
                heading == 'Questions to Ministers')
              debate_index = debate_index.next
              answers = OralAnswers.new({
                :name => heading,
                :date => get_date,
                :publication_status => publication_status,
                :debate_index => debate_index,
                :source_url => @parliament_url,
                :css_class => 'qoa',
                :hansard_volume => @hansard_volume,
                :start_page => @page
              })

              hit_first_question = false
              answers_array << answers
            else
              raise 'unexpected h2 in oral answers: ' + node.to_s
            end
          elsif node.name == 'div'
            # should be handled in the handling of 'h4'
          elsif node.name == 'a'
            @page = node['name'].sub('page_','').to_i
          elsif (node.name == 'p' and (node.to_s.include?('took the Chair') || node.to_s.include?('Prayers') || node.to_s.include?('Karakia') ))
            # ignore
          elsif (not(hit_first_question) and node.name == 'p')
            handle_paragraph node, answers
          else
            raise 'unexpected element under "QOA"[' + index.to_s + ']: ' + node.to_s
          end
        end
      end unless no_questions

      answers_array
    end

    def is_date? text
      if (/^[mtwf][a-z]+, \d\d? [jfmasond][a-z]+ \d\d\d\d$/.match text.downcase)
        true
      else
        false
      end
    end

    def part_of_the_debate_title? debate, text
      debate.name.include?(text) && !@speaker_recalled
    end

    def part_of_the_subdebate_title? debate, text
      debate.sub_debates.size > 0 && debate.sub_debate.name.include?(text)
    end

    def part_of_parent_or_subdebate_title? debate, text
      begin
        debate.debate.name.include?(text) || debate.name.include?(text)
      rescue Exception => e
        puts text
        raise e
      end
    end

    def speaker_recalled_title? title_h, type, text
      type == title_h && (text == 'Speaker Recalled')
    end

    def raise_unexpected node, name, sub=''
      raise "found #{node.name} not in #{sub}debate name #{name}: #{node.to_s}"
    end

    def handle_h1_h2_h3 node, debate
      title_h = @title_is_h2 ? 'h2' : 'h1'
      text = node.inner_html.to_clean_s
      type = node.name

      if part_of_the_debate_title?(debate, text)
        # ignore
      elsif speaker_recalled_title?(title_h, type, text)
        @speaker_recalled = true
        header = SectionHeader.new :text => text
        debate.contributions << header

      elsif debate.is_a?(ParentDebate)
        raise_unexpected(node, debate.sub_debate.name, 'sub-') unless part_of_the_subdebate_title?(debate, text)

      elsif debate.is_a?(SubDebate)
        @speaker_recalled = false
        if part_of_parent_or_subdebate_title?(debate, text) || is_date?(text)
          # ignore
        elsif type == title_h
          sub_debates = debate.debate.sub_debates
          next_index = sub_debates.index(debate) + 1
          if (sub_debates.size < (next_index+1))
            raise 'expected more sub-debates than: ' + sub_debates.size.to_s + " (hit #{title_h}: #{node.to_s} in debate: #{debate.name}, parent debate: #{debate.debate.name})"
          end
          debate = sub_debates[next_index]
          raise "expected sub_debate for #{title_h}: " + node.to_s + ', but found: ' + debate.name unless (debate.name == text)
        else
          raise_unexpected(node, debate.name)
        end
      elsif debate.is_a?(DebateAlone)
        raise_unexpected(node, debate.name) unless is_date?(text)
      else
        raise_unexpected(node, debate.name)
      end

      debate
    end

    def handle_independent_vote_cast name, cast, vote
      vote_cast = VoteCast.new :cast => cast,
          :cast_count => 1,
          :vote_label => name,
          :mp_name => name,
          :party_name => 'Independent',
          :present => false,
          :date => @debate_date
      begin
        vote_cast.valid?
      rescue Exception => e
        question = vote.question
        if question.include? 'amendment'
          question = "\n amendment: " + vote.amendment
        elsif vote.question.include? 'motion'
          question = "\n motion: " + vote.motion
        else
          question = "\n question: " + vote.question
        end

        e = Exception.new(e.to_s + question)
        raise e
      end
      vote.vote_casts << vote_cast
    end

    # New Zealand First 3 (Mark, Paraone, Peters); United Future 1 (Turner); ACT New Zealand 2; Independents: Copeland, Field.
    # New Zealand First 3 (Mark, Paraone, Peters); United Future 1 (Turner); ACT New Zealand 2; Independent: Copeland, Field.
    def handle_party_vote_cast type, cast, node, vote, text

      if text.include?('Independent')

        if text.include?('Independent:') && !text.include?(',')
          name = text.split(':')[1].strip.chomp('.').chomp('1').strip
          handle_independent_vote_cast name, cast, vote

        elsif text[/Independents?:/]
          names = text.split(':')[1].chomp('.').split(',')
          names.each do |name|
            handle_independent_vote_cast name.strip, cast, vote
          end
        else
          raise 'unexpected vote cast text: ' + text
        end
      elsif (text.include? '(') && (match = /([^\d]+) (\d+)\.? \(([^\(]+)\)/.match text.strip)
        party_name = match[1]
        cast_count = match[2].to_i
        mps = match[3].split(',').collect{|m| m.strip}
        mps.each do |mp_name|
          vote_cast = VoteCast.new :cast => cast,
              :cast_count => 1,
              :vote_label => mp_name,
              :mp_name => mp_name,
              :party_name => party_name,
              :present => false,
              :date => @debate_date
          vote.vote_casts << vote_cast
        end
      elsif (text.include? '(') && (match = /([^\d]+) \(([^\(]+)\) (\d+)\.?/.match text.strip)
        party_name = match[1]
        cast_count = match[3].to_i
        mps = match[2].split(',').collect{|m| m.strip}
        mps.each do |mp_name|
          vote_cast = VoteCast.new :cast => cast,
              :cast_count => 1,
              :vote_label => mp_name,
              :mp_name => mp_name,
              :party_name => party_name,
              :present => false,
              :date => @debate_date
          vote.vote_casts << vote_cast
        end
      elsif (match = /([^\d]+) (\d+)\.?/.match text.strip)
        party_name = match[1]
        cast_count = match[2].to_i

        vote_cast = VoteCast.new :cast => cast,
            :cast_count => cast_count,
            :vote_label => party_name,
            :party_name => party_name,
            :present => false,
            :date => @debate_date
        vote.vote_casts << vote_cast

      else
        raise 'unexpected vote cast text line: ' + text
      end
    end

    def handle_party_vote_casts type, cast, node, vote
      line = node.next_sibling.inner_html.to_clean_s.sub('<em>','').sub('</em>','')
      if line.include?('Independent: Copeland; Field')
        line.sub!('Independent: Copeland; Field', 'Independents: Copeland, Field')
      end
      if line.include?('Independent')
        parts = line.split('Independent')
        line = parts[0] + 'Independent' + parts[1].gsub(';',',')
        line.sub!('Field, Progressive', 'Field; Progressive')
      end
      casts = line.split(';')
      casts.each do |text|
        if text.strip.size > 1
          handle_party_vote_cast type, cast, node, vote, text
        end
      end
    end

    def handle_personal_vote_casts cast, table, vote
      teller = false
      (table/'td').each do |cell|
        text = cell.inner_html.to_clean_s
        if text.include?('Teller')
          teller = true
        elsif not(text.blank?)
          present = text.ends_with?('(P)')
          name = text.chomp('(P)').strip

          vote_cast = VoteCast.new :cast => cast,
            :cast_count => 1,
            :vote_label => text,
            :mp_name => name,
            :present => present,
            :date => @debate_date

          vote.vote_casts << vote_cast
        end
      end
      if teller #convention seems that teller is last mp in table
        vote.vote_casts.last.teller = true
      end
    end

    def handle_personal_vote_table table, vote
      table.children.each do |node|
        if node.elem?
          name = node.name
          if name == 'caption'
            text = node.inner_html.to_clean_s
            if (match = /Ayes (\d+)/.match text)
              vote.ayes_tally = match[1].to_i
              handle_personal_vote_casts 'aye', table, vote
            elsif (match = /Noes (\d+)/.match text)
              vote.noes_tally = match[1].to_i
              handle_personal_vote_casts 'noe', table, vote
            elsif (match = /Abstentions (\d+)/.match text)
              vote.abstentions_tally = match[1].to_i
              handle_personal_vote_casts 'abstention', table, vote
            else
              raise 'unexpected vote caption: ' + node.to_s
            end
          end
        end
      end
    end

    def handle_personal_vote_text text, placeholder, vote
      if text.include?('That the ')
        parts = text.split('That the ')
        placeholder.text = parts[0].strip
        vote.vote_question = 'That the ' + parts[1]
      else
        placeholder.text = text
      end
    end

    def handle_personal_vote_element element, vote, placeholder, debate
      case element.name
        when 'em'
          vote.vote_question = element.inner_html.to_clean_s
        when 'p'
          vote.vote_result = element.inner_html.to_clean_s if element['class'] == 'VoteResult'
        when 'table'
          if debate.contributions.last != placeholder
            placeholder.vote = vote
            vote.contribution = placeholder
            placeholder.spoken_in = debate
            debate.contributions << placeholder
          end
          handle_personal_vote_table element, vote if element['class'] == 'table vote'
        when 'a'
          if element['name'] && element['name'].include?('page')
            @page = element['name'].sub('page_','').to_i
          end
        when 'ul'
          if vote.vote_result.blank?
            items = (element/'li')
            vote.vote_result = ''
            items.each do |item|
              vote.vote_result += "<p>#{item.inner_html.to_clean_s}</p>"
            end
          else
            proceduals = handle_procedural element
            proceduals.each {|procedual| debate.contributions << procedual}
          end
        else
          raise 'unexpected element in vote: ' + element.name
      end
    end

    def check_for_vote_blanks vote
      type = vote.is_a?(PersonalVote) ? 'personal' : 'party'
      raise "vote.vote_question is blank for #{type} vote: #{vote.reason}... #{vote.result}" if vote.question.strip.blank?
      raise "vote.vote_result is blank for #{type} vote: #{vote.reason}... #{vote.question}" if vote.vote_result.strip.blank?
    end

    def handle_personal_vote div, debate
      placeholder = VotePlaceholder.new :text => ''
      vote = PersonalVote.new :vote_question => '', :vote_result => ''

      div.children.each do |node|
        if node.text?
          handle_personal_vote_text node.to_clean_s, placeholder, vote
        elsif node.elem?
          handle_personal_vote_element node, vote, placeholder, debate
        end
      end

      check_for_vote_blanks(vote)
    end

    def check_vote_text vote, text
      if vote.is_a? PartyVote
        expected = 'A party vote was called for on the question,'
      else
        expected = 'A personal vote was called for on the question,'
      end
      if text != expected
        raise 'vote_text is not as expected: ' + text
      end
    end

    def check_vote_question vote_question
      if vote_question.split.size < 4
        raise 'vote_question text is suspiciously short: ' + vote_question
      end
    end

    def handle_party_vote_table table, vote, placeholder
      vote_text = ''
      vote_question = ''
      caption = table.at('caption')
      caption.children.each do |child|
        if child.text?
          text = child.to_clean_s.strip
          if (match = /(.*)(That the .*)/.match text) || (match = /(.*)(That Vote .*)/.match text)
            vote_text += match[1].strip
            check_vote_text vote, vote_text
            vote_question = match[2]
            check_vote_question vote_question
          elsif !text.blank?
            vote_text += text
            check_vote_text vote, vote_text
          end
        elsif child.elem?
          if child.name == 'em'
            if vote_question.blank?
              vote_question = child.inner_html.to_clean_s
            else
              raise 'unexpected double vote_question text: ' + vote_question + ' AND ' + child.inner_html.to_clean_s
            end
          else
            raise 'unexpected element in vote caption ' + child.to_s
          end
        end
      end
      placeholder.text = vote_text.strip
      vote.vote_question = vote_question
      vote_result = table.at('.VoteResult')
      vote.vote_result = vote_result.inner_html.to_clean_s

      have_ayes = false
      have_noes = false
      have_abstentions = false
      vote_counts = (table/'.VoteCount')
      vote_counts.each do |node|
        text = node.inner_html.to_clean_s
        if (match = /Ayes (\d+)/.match text)
          raise 'double ayes count for vote: ' + vote_question + ' ' + vote.inspect if have_ayes
          vote.ayes_tally = match[1].to_i
          handle_party_vote_casts 'Ayes', 'aye', node, vote
          have_ayes = true
        elsif (match = /Noes (\d+)/.match text)
          raise 'double ayes count for vote: ' + vote_question if have_noes
          vote.noes_tally = match[1].to_i
          handle_party_vote_casts 'Noes', 'noe', node, vote
          have_noes = true
        elsif (match = /Abstentions (\d+)/.match text)
          raise 'double ayes count for vote: ' + vote_question if have_abstentions
          vote.abstentions_tally = match[1].to_i
          handle_party_vote_casts 'Abstentions', 'abstention', node, vote
          have_abstentions = true
        else
          raise 'unexpected vote count: ' + node.to_s
        end
      end
    end

    def handle_party_vote_element element, placeholder, vote, debate
      case element.name
        when 'table'
          if debate.contributions.last != placeholder
            placeholder.vote = vote
            vote.contribution = placeholder
            placeholder.spoken_in = debate
            debate.contributions << placeholder
          end
          handle_party_vote_table element, vote, placeholder
        when 'ul'
          if !vote.vote_result.blank?
            proceduals = handle_procedural element
            proceduals.each {|procedual| debate.contributions << procedual}
          end
        when 'p'
          if element['class'] == 'a'
            raise 'paragraph of type "a" not expected in partyVote div: ' + element.to_s
          else
            handle_paragraph element, debate
          end
        when 'a'
          if element['name'] && element['name'].include?('page')
            @page = element['name'].sub('page_','').to_i
          end
        else
          raise 'unexpected element in party vote: ' + element.name + ': ' + element.to_s
      end
    end

    def handle_party_vote div, debate
      placeholder = VotePlaceholder.new :text => ''
      vote = PartyVote.new :vote_question => '', :vote_result => ''

      div.children.each do |node|
        if node.elem?
          handle_party_vote_element node, placeholder, vote, debate
        elsif node.text? && !node.to_clean_s.blank?
          raise 'unexpected text in party vote: ' + node.to_clean_s
        end
      end

      check_for_vote_blanks vote
    end

    def add_section_header heading, debate
      text = heading.inner_html.to_clean_s
      header = SectionHeader.new :text => text
      debate.contributions << header
    end

    def handle_div div, debate
      case div['class']
        when 'SubDebate'
          handle_contributions div, debate
        when 'Speech'
          handle_contributions div, debate
        when 'partyVote'
          handle_party_vote div, debate
        when 'personalVote'
          handle_personal_vote div, debate
        when 'section'
          if (h4 = div.at('h4'))
            add_section_header h4, debate
          elsif (h3 = div.at('h3'))
            add_section_header h3, debate
          else
            raise 'unexpected div ' + div.to_s
          end
        else
          raise 'unexpected div ' + div.to_s
      end
    end

    def handle_paragraph node, debate
      attributes = contribution_attributes(node)

      if attributes == nil || (is_continue_speech = attributes[:type] == ContinueSpeech && !attributes.has_key?(:speaker) )
        type = node['class']
        if type == 'a' || MAKE_CSS_TYPES.include?(type) || is_continue_speech
          text = node.inner_html.to_clean_s

          if debate.contributions.empty? && (text[/took the Chair/] || text[/Prayers/] || text[/Karakia/])
            # ignore this procedural stuff for now
          else
            raise 'no last contribution for text ' + text unless debate.contributions.last

            css = MAKE_CSS_TYPES.include?(type) ? %Q[ class="#{type}"] : ''
            debate.contributions.last.text += %Q[<p#{css}>#{text}</p>]
          end
        elsif type == 'MsoNormal' || type == 'JHBill' || type == 'Urgency'
          procedural = Procedural.new :text => node.inner_html.to_clean_s
          debate.contributions << procedural
        else
          raise 'what is this: ' + node.to_s
        end
      elsif model_type = attributes[:type]
        attributes[:page] = @page if @page
        contribution = model_type.new(attributes)
        contribution.spoken_in = debate
        debate.contributions << contribution
      end
    end

    def raise_unexpected_element node
      raise "unexpected element in handle_contributions: #{node.to_s} #{node.parent ? node.parent.to_s : ''}"
    end

    def handle_contributions element, debate
      element.children.each do |node|
        case node.name
          when 'p'
            handle_paragraph(node, debate)
          when 'a'
            @page = node['name'].sub('page_','').to_i
          when 'ul'
            proceduals = handle_procedural(node)
            proceduals.each {|p| debate.contributions << p}
          when 'div'
            handle_div(node, debate)
          when 'h1', 'h2'
            debate = handle_h1_h2_h3(node, debate)
          when 'h3'
            debate = handle_h1_h2_h3(node, debate) if @title_is_h2
            raise_unexpected_element(node) unless @title_is_h2
          else
            raise_unexpected_element(node)
        end if node.elem?

        raise "unexpected text #{node.to_s}" if (node.text? && node.to_clean_s.strip.size > 0)
      end
    end

    def create_oral_answer name, answer_root, number_in_name, debate_index
      if (match = /Question No\.? (\d+) to Minister/.match name)
        re_oral_answer_no = $1
      elsif (name != 'Question Time' && !name.starts_with?('Question No.') && name != 'Urgent Question—Leave to Ask' && !name.starts_with?('Personal Explanation') && !name.starts_with?('Urgent Question to Minister') )
        question_p = answer_root.at('.SubsQuestion[1]')
        strongs = (answer_root/'.SubsQuestion[1]/strong')
        if strongs.size > 0
          last = strongs.last.at('text()')
          index = 2
          while (last == nil)
            last = strongs[strongs.size - index].at('text()')
            index = index.next
          end
          to = last.to_clean_s.chomp(':').strip
        else
          raise 'unexpected absence of strong elements: ' + name
        end

        if number_in_name
          if (match = /(\d+)\. (.*)/.match name)
            oral_answer_no = $1.to_i
            name = $2
          else
            raise 'cannot find oral answer number: ' + name
          end
        else
          if (match = /(\d+)\.?.*/.match strongs.first.inner_html)
            oral_answer_no = $1.to_i
          elsif (match = /(\d+)\.?.*/.match question_p.inner_html)
            oral_answer_no = $1.to_i
          else
            raise 'cannot find oral answer number: ' + name
          end
        end
      end

      if name.ends_with? '—'
        raise "didn't expect oral question name to end with '—': " + name
      end
      debate = OralAnswer.new :name => name.sub(" —","—"),
          :date => get_date,
          :publication_status => publication_status,
          :css_class => 'oralanswer',
          :debate_index => debate_index,
          :question_to => to,
          :source_url => @parliament_url,
          :oral_answer_no => oral_answer_no,
          :re_oral_answer_no => re_oral_answer_no,
          :hansard_volume => @hansard_volume,
          :start_page => @page

      handle_contributions answer_root, debate
      if debate.contributions.size > 0
        question = debate.contributions.first
        if question.text[/^<p>#{debate.oral_answer_no}\./]
          question.text = question.text.sub(/^<p>#{debate.oral_answer_no}\./, '<p>')
        end
      end
      debate
    end

    # <ul class="">
      # <li>Sandra Goudie withdrew from the Chamber.</li>
    # </ul>
    def handle_procedural node
      proceduals = []
      node.children.each do |child|
        if child.elem?
          if child.name == 'li'
            procedual = Procedural.new(:text => '<p>'+child.inner_html.to_clean_s+'</p>')
            proceduals << procedual
          else
            raise 'unexpected element ' + node.to_s
          end
        elsif (child.text? and child.to_clean_s.strip.size > 0)
          raise 'unexpected text ' + child.to_clean_s + node.to_s
        end
      end
      proceduals
    end

    def populate_from_text text, type, node, a
      if (type == SubsQuestion and text.sub(',','').strip == 'to the')
        @to_the = true
      elsif (text.to_clean_s.sub(', ','').strip.starts_with?('on behalf of'))
        @on_behalf_of = true
      else
        text.sub!(':','').strip! if text.starts_with?(':')
        a[:text] += text
      end
    end

    def populate_from_element type, node, a, spoken
      name = node.name
      if name == 'a'
        if node['name'].include?('time_')
          a[:time] = node['name'].sub('time_','')
        else
          raise 'unexpected a element: ' + node.to_s
        end
      elsif (name == 'strong' and spoken)
        text = node.inner_html.to_clean_s
        if (type == SubsQuestion and /\d+\. (.+)$/.match(text))
          a[:speaker] = $1.strip
        elsif (type == SubsQuestion and /\d+\.?[ ]?/.match(text))
          # ignore
        elsif text.strip.size < 2
          # ignore
        elsif @to_the
          @to_the = false
        elsif @on_behalf_of
          a[:on_behalf_of] = text
          @on_behalf_of = false
        elsif a[:speaker]
          a[:speaker] += ' '+text
          a[:speaker].squeeze(' ')
        else
          a[:speaker] = text
        end
      elsif name == 'em'
        a[:text] += ' ' + node.to_s.to_clean_s
      elsif name == 'strong'
        a[:text] += ' ' + node.to_s.to_clean_s
      else
        raise "unexpected element in #{type.name} spoken paragraph: " + node.to_s
      end
    end

    def populate_contribution_attributes type, paragraph, spoken=true
      type = Object.const_get(type)
      a = {:type => type}
      a[:text] = '<p>'
      @to_the = false
      @on_behalf_of = false

      paragraph.children.each do |node|
        if node.text? && (text = node.to_clean_s).size > 0
          populate_from_text text, type, node, a
        elsif node.elem?
          populate_from_element type, node, a, spoken
        end
      end
      a[:text] += '</p>'
      a
    end

    SPOKEN_TYPES = ['SubsQuestion', 'SubsAnswer', 'SupQuestion', 'SupAnswer',
        'Speech', 'Interjection', 'Intervention',
        'ContinueSpeech', 'ContinueIntervention',
        'ContinueQuestion', 'ContinueAnswer']

    NON_SPOKEN_TYPES = ['Quotation', 'Translation',
        'Clause', 'ClauseAlone',
        'Clause-Description', 'Clause-Description0',
        'Clause-Heading', 'Clause-Indent1', 'Clause-Indent2', 'Clause-Indent3',
        'Clause-Outline', 'Clause-Part',
        'Clause-Paragraph', 'Clause-SubClause', 'Clause-SubParagraph']

    MAKE_CSS_TYPES = ['Incorporation', 'AgreementByLeave', 'AgreementByLeave-points']

    def contribution_attributes paragraph
      type = paragraph['class']

      if type.blank?
        raise 'unexpected absence of class attribute: ' + paragraph.to_s

      elsif SPOKEN_TYPES.include?(type)
        populate_contribution_attributes type, paragraph
      elsif (type == 'a' || MAKE_CSS_TYPES.include?(type) ||
          type == 'MsoNormal' || type == 'JHBill' || type == 'Urgency')
        nil
      elsif NON_SPOKEN_TYPES.include?(type)
        type = type.sub('-','').sub('0','')
        populate_contribution_attributes type, paragraph, false
      else
        raise 'unexpected type: ' + paragraph.to_s
      end
    end

    def create_debate_alone debate_index
      name = (((@doc/'.DebateAlone/h2').last) / 'text()')[0].to_clean_s
      debate = DebateAlone.new :name => name,
          :date => get_date,
          :publication_status => publication_status,
          :css_class => 'debatealone',
          :debate_index => debate_index,
          :source_url => @parliament_url,
          :hansard_volume => @hansard_volume
      handle_contributions @doc.at('.DebateAlone'), debate
      debate
    end

    def debate_headings(type)
      headings = (@doc/".#{type}/h2")
      if headings.empty?
        headings = (@doc/".#{type}/h1")
        @title_is_h2 = false
      end
      headings
    end

    def find_name_and_sub_names type, sub_names=[]
      headings = debate_headings(type)
      name = headings.first.at('text()').to_clean_s
      if is_date? name
        name = headings[1].at('text()').to_clean_s
        headings = headings[1, headings.length-1]
      end

      if headings.size > 1
        sub_names << headings[1].at('text()').to_clean_s

        sibling = headings[1].next_sibling
        while sibling
          if sibling.elem? && sibling.name == 'h2'
            sub_names << sibling.inner_html.to_clean_s
          end
          sibling = sibling.next_sibling
        end
      end

      raise "can't find sub heading" if sub_names.empty?

      return name, sub_names
    end

    def make_parent_debate name, debate_index, sub_names
      debate = ParentDebate.new :name => name,
          :date => get_date,
          :publication_status => publication_status,
          :css_class => 'debate',
          :debate_index => debate_index,
          :source_url => @parliament_url,
          :hansard_volume => @hansard_volume,
          :sub_names => sub_names

      debate.valid?
      debate.sub_debates.each { |sub_debate| sub_debate.debate = debate }
      debate
    end

    def make_when_sub_debates_empty debate_index, type
      name, sub_names = find_name_and_sub_names(type)
      debate = make_parent_debate(name, debate_index, sub_names)
      handle_contributions @doc.at(".#{type}"), debate.sub_debates[0]
      debate
    end

    def remove_empty_sub_debate empty_sub_debates, debate
      headings = empty_sub_debates.collect(&:name).join(', ')
      sub_debates = debate.sub_debates
      empty_sub_debates.each do |empty_sub_debate|
        sub_debates.delete(empty_sub_debate)
        empty_sub_debate.debate = nil
      end

      raise "expected there to be a single sub_debate, but got: #{sub_debates.size}" unless sub_debates.size == 1
      raise "expected there to be a single empty sub_debate, but got: #{empty_sub_debates.size}" unless empty_sub_debates.size == 1

      sub_debate = sub_debates.first
      sub_debate.debate_index = debate.debate_index + 1
      sub_debate.sub_name = sub_debate.name
      sub_debate.name = "#{empty_sub_debates.first.name}, #{sub_debate.name}"
      debate.sub_debates = sub_debates
    end

    def make_when_sub_debates_not_empty debate_index, type, sub_debates
      headings = debate_headings(type)
      sub_names = []
      sub_debates.each { |sub_debate| add_sub_heading(sub_debate, sub_names) }

      name, sub_names = find_name_and_sub_names type, sub_names
      debate = make_parent_debate(name, debate_index, sub_names)

      if sub_debates.size == sub_names.size
        sub_debates.each_with_index do |sub_debate, index|
          handle_contributions sub_debate, debate.sub_debates[index]
        end
      else
        handle_mixed_subdebates type, debate
      end

      empty_sub_debates = debate.sub_debates.select {|sub_debate| sub_debate.contributions.empty?}
      remove_empty_sub_debate(empty_sub_debates, debate) unless empty_sub_debates.empty?

      debate
    end

    def handle_mixed_subdebates type, debate
      nodes = @doc.at(".#{type}").children
      index = -1
      nodes.each do |node|
        if node.name == 'div' && node['class'] == 'SubDebate'
          index = index.next
          handle_contributions node, debate.sub_debates[index]
        elsif node.name == 'a'
          @page = node['name'].sub('page_','').to_i
        elsif node.name == 'p' && node['class'] == 'Urgency'
          procedural = Procedural.new :text => node.inner_html.to_clean_s
          debate.contributions << procedural
        else
          begin
            text = node.at('text()').to_clean_s
          rescue Exception => e
            puts node.insp
            raise e
          end
          if node.name[/^h\d$/] && text == debate.sub_debates[index+1].name
            index = index.next
          elsif !is_date?(text) && text != debate.name
            handle_div node, debate.sub_debates[index]
          end
        end if node.elem?
      end
    end

    def create_debate debate_index, type
      sub_debates = (@doc/'.SubDebate')
      if sub_debates.empty?
        make_when_sub_debates_empty debate_index, type
      else
        make_when_sub_debates_not_empty debate_index, type, sub_debates
      end
    end

    def create_bill_debate debate_index
      text = (@doc/'.BillDebate/h2[1]/text()')[0]
      if text
        name = text.to_clean_s
        name = (@doc/'.BillDebate/h2[2]/text()')[0].to_clean_s if is_date?(name)
        sub_name = (@doc/'.SubDebate/h3[1]/text()')[0].to_clean_s
      else
        name = (@doc/'.BillDebate/h1[1]/text()')[0].to_clean_s
        name = (@doc/'.BillDebate/h1[2]/text()')[0].to_clean_s if is_date?(name)
        sub_name = (@doc/'.SubDebate/h2[1]/text()')[0].to_clean_s
        @title_is_h2 = false
      end
      make_bill_debate name, sub_name, debate_index, 'BillDebate', 'billdebate'
    end

    def document_title
      (@doc/'.copy/.section[1]/h1[1]/text()')[0].to_clean_s
    end

    def create_bill_debate_from_debate_debate debate_index
      names = document_title.split('—')
      name = names[0].strip
      sub_name = names[1].strip
      make_bill_debate name, sub_name, debate_index, 'DebateDebate', 'billdebate'
    end

    def create_bill_debate_from_bill_debate2 debate_index
      names = document_title.split('—')
      name = names[0..(names.size-2)].join('—').strip
      sub_name = names.last.strip
      make_bill_debate name, sub_name, debate_index, 'BillDebate2', 'billdebate2'
    end

    def create_bill_debate_from_bill_debate_mid debate_index
      names = document_title.split('—')
      name = names[0..(names.size-2)].join('—').strip
      sub_name = names.last.strip
      make_bill_debate name, sub_name, debate_index, 'BillDebateMid', 'billdebate_mid'
    end

    def add_sub_heading sub_debate, sub_names
      h_element = @title_is_h2 ? 'h3' : 'h2'
      sub_heading = (sub_debate/"#{h_element}[1]/text()")

      if sub_heading.size > 0 || (sub_heading = (sub_debate/"h2[1]/text()") ).size > 0
        sub_names << sub_heading[0].to_clean_s
      else
        raise "can't find sub heading"
      end
    end

    def add_sub_headings sub_debates
      sub_names = []
      sub_debates.each { |sub_debate| add_sub_heading(sub_debate, sub_names) }

      sibling = sub_debates.last.next_sibling
      while sibling
        if (sibling.elem? and sibling.name == 'h2')
          sub_name = sibling.inner_html.to_clean_s
          sub_names << sub_name if sub_name != 'Speaker Recalled'
        end
        sibling = sibling.next_sibling
      end
      sub_names
    end

    def add_more_sub_headings sub_names, headings
      title = document_title
      headings.each do |heading|
        if heading.size > 0 && title.include?(heading)
          sub_names << heading
        else
          raise "unexpected heading: #{heading}"
        end
      end
      sub_names
    end

    def make_bill_debate name, sub_name, debate_index, type, css_class
      sub_names = [sub_name]
      sub_debates = (@doc/'.SubDebate')
      sub_names = add_sub_headings(sub_debates) if sub_debates.size > 0

      headings = (@doc/'.BillDebate/h1/text()').collect(&:to_clean_s).select{|x| !is_date?(x)}
      if headings.size > 1
        headings = headings[1, headings.length-1]
        sub_names = add_more_sub_headings(sub_names, headings)
      end

      debate = BillDebate.new :name => name,
          :sub_names => sub_names,
          :date => get_date,
          :publication_status => publication_status,
          :css_class => css_class,
          :debate_index => debate_index,
          :source_url => @parliament_url,
          :hansard_volume => @hansard_volume

      debate.valid?
      debate.sub_debates.each {|sub_debate| sub_debate.debate = debate}

      if sub_debates.size == 0 || sub_debates.size == 1
        handle_contributions @doc.at('.'+type), debate.sub_debates[0]
      else
        handle_mixed_subdebates 'BillDebate', debate
      end
      debate
    end
end

class String
  def to_clean_s
    to_s.mb_chars.gsub("\r\n",' ').gsub("\n",' ').squeeze(' ').gsub(' ,',',').strip.to_s
  end
end

module Hpricot
  class Text
    def to_clean_s
      to_s.to_clean_s
    end
  end
end
