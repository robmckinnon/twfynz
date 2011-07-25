module DebatesHelper

  def format_debate_category(category)
    if category == 'debates'
      'Parliamentary debates'
    else
      category.gsub('_',' ').titleize
    end
  end

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

  def format_bill_link_in_text text, bill
    if bill and bill.is_a? Bill
      bill_link = link_to(bill.bill_name, show_bill_url(:bill_url => bill.url))
      text.gsub!(bill.bill_name, bill_link)
    end
    text
  end

  def format_vote_question vote
    question = String.new vote.question
    format_bills_in_text vote.contribution, question
  end

  def format_bills_in_text contribution, text
    debate = contribution.debate

    if (bills = debate.related_bills) && bills.size > 0
      bills.each { |bill| format_bill_link_in_text(text, bill) }
    elsif (bill = debate.about)
      format_bill_link_in_text text, bill
    end

    text
  end

  def format_bill_in_contribution transcript, text, date
    bills = Bill.bills_from_text_and_date text, date
    bills.compact.each do |bill|
      bill_name = bill.bill_name
      bill_link = link_to(bill_name, show_bill_url(:bill_url => bill.url))
      transcript.gsub!(bill_name, bill_link)

      transcript.gsub!(bill_name.gsub("'","’"), bill_link) if bill_name.include?("'")
    end
  end

  def format_contribution contribution, organisations, organisation_names
    transcript = contribution.html

    if contribution.is_question?
      # opening = '\1<span class="speechtype">Question:</span> '
      # transcript.sub!(/(<p[^>]*>)[ ]?/, opening)

    elsif contribution.is_answer?
      # opening = '\1<span class="speechtype">Answer:</span> '
      # transcript.sub!(/(<p[^>]*>)[ ]?/, opening)

    elsif contribution.is_a? SectionHeader
      transcript.sub!('<p>','<h3>').sub!('</p>','</h3>')

    elsif contribution.is_procedural? && (match = /Debate resumed from ([^.]*)\./.match(transcript)) && contribution.debate.about
      date = Date.parse(match[1])
      debate_date = contribution.debate.date
      if date > debate_date
        date = Date.new(date.year - 1, date.month, date.day)
      end
      continued_from = contribution.debate.about.sub_debates.select{|d| d.date == date}
      transcript.sub!(match[1], link_to(match[1], get_url(continued_from.first))) unless continued_from.empty?
    elsif contribution.debate.name.include?('Reading') && transcript.include?('I move') && transcript.include?('That the ') && transcript.include?('be now read')
      text = transcript[/That the (.*)be now read/, 1]
      format_bill_in_contribution transcript, text, contribution.spoken_in.date
    elsif transcript[/read a .* time/]
      transcript = format_bills_in_text(contribution, transcript)
    elsif contribution.debate.name == 'Business Statement' && contribution.debate.contributions.index(contribution) == 0
      # format_bill_in_contribution transcript, text, contribution.spoken_in.date
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
          transcript.sub!(name, '<a href="/organisations/'+organisation.slug+'">'+name+'</a>')
        end
      end
    end
    if contribution.is_procedural?
      if transcript.starts_with?('<p>The question was put') || transcript[/^<p>Bills? read a/]
        transcript = link_to_this_contribution(contribution) + transcript
      end
    end
    transcript
  end

  @@mp_id_to_link = {}

  def mp_link contribution
    if contribution.is_a?(SubsQuestion) && contribution.mp
      number = contribution.debate.oral_answer_no ? contribution.debate.oral_answer_no.to_s+'. ' : ''
      url = show_mp_url(:name => contribution.mp.id_name)
      return link_to(portrait(contribution.mp),url) + number + link_to(contribution.speaker_name.name, url)
    end

    key = contribution.spoken_by_id.to_s + contribution.speaker_name.name

    unless @@mp_id_to_link.has_key? key
      if contribution.mp
        @@mp_id_to_link[key] = link_to(portrait(contribution.mp) + contribution.speaker_name.name, show_mp_url(:name => contribution.mp.id_name))
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
        speaker += link_to_this_contribution(contribution)
        if @debate.about.is_a? Bill
          speaker += '<br /> to the Member in charge of the ' + link_to_about(@hash, @about, @about_type)
        elsif @debate.answer_from
          speaker += '<br /> to the ' + @debate.answer_from.title.sub(@about.full_name, link_to_about(@hash, @about, @about_type))
        end
      else
        speaker += link_to_this_contribution contribution
      end
      speaker
    else
      contribution.speaker
    end
  end

  def get_preceding_divider contribution
    previous_contribution = contribution.previous_in_debate
  end

  def get_preceding_divider_for contribution, previous_contribution
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
