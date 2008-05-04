module DebatesHelper

  def status_description debate
    case debate.publication_status
      when 'F'
        ''
      when 'A'
        ' (advance copy)'
      when 'U'
        ' (uncorrected copy)'
    end
  end

  def format_bill_link_in_vote_question question, bill
    if bill and bill.is_a? Bill
      bill_link = link_to(bill.bill_name, show_bill_url(:bill_url => bill.url))
      question.gsub!(bill.bill_name, bill_link)
    end
  end

  def format_vote_question vote
    debate = vote.contribution.debate
    question = String.new vote.question

    if (not debate.is_a? DebateAlone) and (debate.parent.type.to_s == 'BillDebate')
      bill = debate.about
      if bill
        format_bill_link_in_vote_question question, bill
      elsif debate.debate_topics
        debate.debate_topics.each { |topic| format_bill_link_in_vote_question question, topic.topic }
        question
      end
    else
      question
    end
  end

  def format_contribution contribution, organisations, organisation_names
    transcript = contribution.html ''

    if contribution.is_question?
      opening = '\1<span class="speechtype">Question:</span> '
      transcript.sub!(/(<p[^>]*>)[ ]?/, opening)

    elsif contribution.is_answer?
      opening = '\1<span class="speechtype">Answer:</span> '
      transcript.sub!(/(<p[^>]*>)[ ]?/, opening)

    elsif contribution.is_a? SectionHeader
      transcript.sub!('<p>','<h3>').sub!('</p>','</h3>')

    elsif contribution.is_procedural? && (match = /Debate resumed from ([^.]*)\./.match transcript) && contribution.debate.about
      date = Date.parse(match[1])
      debate_date = contribution.debate.date
      if date > debate_date
        date = Date.new(date.year - 1, date.month, date.day)
      end
      continued_from = contribution.debate.about.sub_debates.select{|d| d.date == date}
      transcript.sub!(match[1], link_to(match[1], get_url(continued_from.first))) unless continued_from.empty?
    elsif contribution.debate.name.include?('Reading') and transcript.include?('I move') and transcript.include?('That the ') and transcript.include?('be now read')
      bill_text = transcript.match(/That the (.*)be now read/)[1].gsub('Bill and the','Bill, and the')
      bills = bill_text.split(/,( and)? the/).collect do |name|
        name = name.match(/[a-z ]*(.*)/)[1]
        name.chomp!(', ') if name.length > 0
        if (name.length > 0 and (name.strip.length > 0))
          Bill.from_name_and_date(name.strip, contribution.spoken_in.date)
        else
          nil
        end
      end
      bills.compact.each do |bill|
        bill_link = link_to(bill.bill_name, show_bill_url(:bill_url => bill.url))
        transcript.gsub!(bill.bill_name, bill_link)
      end
    end

    downcase = transcript.downcase
    organisation_names.each_with_index do |names, index|
      names.each do |name|
        if name.include? ' '
          if downcase.include? name.downcase
            organisation = organisations[index]
            transcript.sub!(/(#{name})/i, '<a href="/organisations/'+organisation.slug+'">\1</a>')
          end
        elsif transcript.include? name
          organisation = organisations[index]
          transcript.sub!(name, '<a href="/organisations/'+organisation.slug+'">\1</a>')
        end
      end
    end
    transcript
  end

  @@mp_id_to_link = {}

  def mp_link contribution
    key = contribution.spoken_by_id.to_s + contribution.speaker_name.name

    unless @@mp_id_to_link.has_key? key
      if contribution.mp
        @@mp_id_to_link[key] = link_to(portrait(contribution.mp) + contribution.speaker_name.name, mp_url(:name => contribution.mp.id_name))
      else
        @@mp_id_to_link[key] = contribution.speaker
      end
    end

    @@mp_id_to_link[key]
  end

  def link_to_this_contribution contribution
    " #{link_to_contribution('Link to this', contribution, nil, 'link_to_contribution')}"
  end

  def speaker_link contribution
    speaker = ''
    if contribution.spoken_by_id
      speaker = mp_link contribution

      if contribution.speaker_name.remaining
        remaining = contribution.speaker_name.remaining
        if contribution.is_a?(SubsAnswer) && @about
          remaining = remaining.sub(@about.full_name, link_to_about(@hash, @about, @about_type))
        end
        speaker += ' ('+remaining+')'
      end

      if contribution.is_a? SubsQuestion
        speaker += link_to_this_contribution contribution
        if @debate.about.is_a? Bill
          speaker += '<br /> to the Member in charge of the ' + link_to_about(@hash, @about, @about_type)
        elsif @debate.answer_from
          speaker += '<br /> to the ' + @debate.answer_from.title.sub(@about.full_name, link_to_about(@hash, @about, @about_type))
        end
      else
        speaker += link_to_this_contribution contribution
      end
    else
      speaker = contribution.speaker
    end
    speaker
  end

  def get_preceding_divider contribution
    previous_contribution = contribution.previous_in_debate

    if (contribution.is_question? ||
        (contribution.is_speech? &&
            !( previous_contribution.is_a?(SectionHeader) ||
                previous_contribution.is_vote?) ) ||
        (contribution.is_procedural? &&
            !( contribution.text.starts_with?('<p>Amendment') ||
                previous_contribution.is_vote? ||
                previous_contribution.is_interjection?) ) ||
        (contribution.is_interjection? and previous_contribution.is_procedural?) )
      'divider2'
    else
      'divider3 '
    end
  end
end
