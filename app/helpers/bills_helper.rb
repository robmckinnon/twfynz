module BillsHelper

  def submission_alert bill
    if (bill.respond_to? :submission_dates and (bill.submission_dates.size > 0))
      submission_date = bill.submission_dates[0]
      if Date.today <= submission_date.date
        url = "http://www.parliament.nz/en-NZ/SC/SubmCalled#{submission_date.parliament_url}"
        details = submission_date.details.chomp('.')
        %Q[#{link_to(details, url)} (link to external Parliament website).]
      else
        ''
      end
    else
      ''
    end
  end

  def committee_report_details bill, event_name
    details = ''
    if bill.was_reported_by_committee?
      details = %Q[The #{link_to_committee(bill.referred_to_committee)} reported on this bill.]
    end
    if bill.nzl_events
      events = bill.nzl_events.select {|e| e.version_stage == 'reported' || e.version_stage == 'wip version updated' }.sort_by(&:publication_date)
      if events.size > 0
        details += %Q[ #{link_to('View the bill', events.last.link)} as reported from the #{events.last.version_committee} at the New Zealand Legislation website.]
      end
    end
    details
  end

  def committee_details bill, event_name
    if bill.is_before_committee?
      %Q[The #{link_to_committee(bill.referred_to_committee)} is considering this bill.]
    end
  end

  def mp_in_charge bill
    %Q[#{link_to_mp(bill.member_in_charge)} #{is_was(bill)} the member in charge of this #{bill_type(bill).camelize}.]
  end

  def is_was bill
    bill.current? ? 'is' : 'was'
  end

  def debate_date date, debates
    if debates.nil?
      format_date date
    elsif debates.size == 1
      format_date debates.first.date
    else
      debate_dates debates
    end
  end

  def debate_dates debates
    debates.reverse.collect do |d|
      date = format_date(d.date)
      date += ' (resumed)' if (d.contributions.size > 0 and d.contributions.first.text.include? 'Debate resumed')
      link_to(date, get_url(d))
    end.join(',<br />')
  end

  def missing_votes? events_by_date
    no_data = false
    events_by_date.each do |date_event|
      unless @debates_by_name
        date = date_event[0]
        name = date_event[1]
        if date < Date.parse('2005-11-01') and name.include? 'Reading'
          no_data = true
        end
      end
    end
    no_data
  end

  def vote_question vote
    vote ? vote.question : ''
  end

  def no_vote debates, date, name
    if debates.nil?
      if date < Date.parse('2005-11-01') and name.include? 'Reading'
        '&nbsp;n/a *'
      else
        ''
      end
    else
      false
    end
  end

  def vote_ayes votes, debates, date, name
    if (non_vote = no_vote debates, date, name)
      non_vote
    elsif votes and votes.size > 0
      votes.collect { |v| (v and v.ayes_count != 0) ? v.ayes_count : '-' }.join('<br /><br />')
    else
      ''
    end
  end

  def vote_noes votes, debates, date, name
    if (non_vote = no_vote debates, date, name)
      non_vote
    elsif votes and votes.size > 0
      votes.collect { |v| (v and v.noes_count != 0) ? v.noes_count : '-' }.join('<br /><br />')
    else
      ''
    end
  end

  def vote_abstentions votes, debates, date, name
    if (non_vote = no_vote debates, date, name)
      non_vote
    elsif votes and votes.size > 0
      votes.collect { |v| (v and v.abstentions_count != 0) ? v.abstentions_count : '-' }.join('<br /><br />')
    else
      ''
    end
  end

  def result_from_vote debate, votes, bill=nil
    result = votes.select {|v| v}.collect {|v| v.result}.join('<br /><br />')

    if votes.size == 1
      contributions = debate.contributions
      last = contributions.last
      if last.is_procedural?
        if last.text.gsub(/<[pi]>/, '').gsub(/<\/[pi]>/,'') == 'Motion agreed to.'
          result += '<br /><br />' + last.text.gsub(/<[pi]>/, '').gsub(/<\/[pi]>/,'').chomp('.') + ':<br />'
          if (contributions.size > 1 and contributions[contributions.size-2].is_speech?)
            if match = contributions[contributions.size-2].text.match(/That the .*/)
              result += match[0].gsub(/<[pi]>/, '').gsub(/<\/[pi]>/,'')
            end
          end
        else
          result += '<br /><br />' + last.text.gsub(/<[pi]>/, '').gsub(/<\/[pi]>/,'')
        end
      elsif (contributions.size > 1 and contributions[contributions.size-2].is_procedural?)
        result += '<br /><br />' + contributions[contributions.size-2].text.gsub(/<[pi]>/, '').gsub(/<\/[pi]>/,'')
      end
    end

    result = make_committee_a_link result, bill, votes
    result
  end

  def result_from_contributions debate, bill=nil
    if debate.contributions.size == 0
      ''
    else
      contributions = debate.contributions.reverse
      i = 0
      statement = contributions[i]
      results = []

      if statement.text.gsub(/<[pi]>/, '').gsub(/<\/[pi]>/,'') == 'Motion agreed to.'
        result = statement.text.gsub(/<[pi]>/, '').gsub(/<\/[pi]>/,'').chomp('.') + ':<br />'

        if (contributions.size > 1 and contributions[1].is_speech?)
          if match = contributions[1].text.match(/That the .*/)
            result += match[0].gsub(/<[pi]>/, '').gsub(/<\/[pi]>/,'').gsub('</i>','')
          end
        end

        if (contributions.size > 2 and contributions[2].is_procedural?)
          if contributions[2].text.include? 'Bill read'
            result = contributions[2].text.gsub(/<[pi]>/, '').gsub(/<\/[pi]>/,'') + '<br /><br />' + result
          end
        end

        result.sub!(':<br />','.') if result.ends_with?(':<br />')
      else
        while (statement and statement.is_procedural?)
          results << statement.text.gsub(/<[pi]>/, '').gsub(/<\/[pi]>/,'') unless statement.text[/(Waiata|Sitting suspended)/]
          i = i.next
          statement = (i != contributions.size) ? contributions[i] : nil
          statement = nil if (statement and statement.text.include? 'House resumed')
          statement = nil if (statement and statement.text.gsub('<p>', '').strip[/^(Clause|\[An interpretation)/])
        end
        result = results.reverse.flatten.join('<br /><br />')
      end
      result = make_committee_a_link result, bill
      result
    end
  end

  def introduction bill
    intro = mp_in_charge(bill)
    if bill.nzl_events
      events = bill.nzl_events.select {|e| e.version_stage == 'introduction'}.sort_by(&:publication_date)
      if events.size > 0
        intro += %Q[<br/><br/>#{link_to('View the bill', events.last.link)} at introduction at the New Zealand Legislation website.]
      end
    end
  end

  def bill_event_summary name, votes, bill, debates
    if debates.nil?
      if name == 'Introduction'
        introduction @bill
      elsif name == 'Submissions Due'
        committee_details @bill, name
      elsif name == 'SC Reports'
        committee_report_details @bill, name
      elsif name == 'Committee of the whole House: Order of the day for committal discharged'
        'Order of the day for committal discharged.'
      elsif name == 'Consideration of report: Order of the day for consideration of report discharged'
        'Order of the day for consideration of report discharged.'
      elsif name == 'Second reading: Order of the day for second reading discharged'
        'Order of the day for second reading discharged.'
      elsif name == 'First reading: Order of the day for first reading discharged'
        'Order of the day for first reading discharged.'
      else
        ''
      end
    elsif votes
      result_from_vote debates.first, votes, bill
    else
      result_from_contributions debates.first, bill
    end
  end

  def vote_result vote
    vote ? vote.result : ''
  end

  private

    def make_committee_a_link result, bill, votes=nil
      if bill
        committee = bill.referred_to_committee
        if (committee and result.include?(committee.full_committee_name))
          name = committee.full_committee_name
          result.sub!(name, link_to(name, show_committee_url(:committee_url => committee.url) ) )
        elsif (match = (/the (.* Committee)/.match result))
          name = match[1]
          committee = Committee::from_name name
          if committee
            if votes
              votes.each do |vote|
                if (vote.votes_count > 0 and (vote.ayes_count > vote.noes_count))
                  bill.referred_to_committee = committee
                  bill.save
                end
              end
            end
            result.sub!(name, link_to(name, show_committee_url(:committee_url => committee.url) ) )
          end
        end
      end
      result
    end
end
