# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # alias_method :old_method_missing, :method_missing

  # def set_the_app app
    # @the_app = app
  # end

  # def method_missing symbol, *args
    # if symbol.to_s.ends_with?('url') && @the_app
      # @the_app.send(symbol, args)
    # else
      # old_method_missing symbol, *args
    # end
  # end

  def calendar_nav current_date, heading_prefix=''
    first_sitting = SittingDay.find(:all).select{|s| s.date.year == current_date.year && s.date.month == current_date.month}.first
    if first_sitting
      calendar(:year => current_date.year, :month => current_date.month, :heading_prefix => heading_prefix) do |date|
        if date.is_sitting_day?
          display = date.has_debates? ? to_show_debates_on_date_url(date) : date.mday
          css_class = "sitting-day"
          css_class = css_class + ' current-day' if date.mday == current_date.day
          [display, {:class => "sitting-day", :title => 'Sitting day'+title_for_sitting_day(date)}]
        else
          [date.mday, nil]
        end
      end
    else
      month = Date::MONTHNAMES[current_date.month][0..2]
      %Q|<table class="calendar" border="0" cellpadding="0" cellspacing="0"><thead><tr class="monthName"><th>#{heading_prefix} #{month} #{current_date.year}</th></tr></thead><tbody><tr><td style="text-align:center">(no sittings in  #{month} #{current_date.year})</td></tr></tbody></table>|
    end
  end

  def to_show_debates_on_date_url date
    link_to date.mday, show_debates_on_date_url({:url_category=>'debates'}.merge(Debate::to_date_hash(date)) )
  end

  def title_for_sitting_day date
    title = ''
    if date.has_final?
      title = ' with final debates'
    elsif date.has_advance?
      title = ' with advance debates'
    elsif date.has_oral_answers?
      title = ' with uncorrected oral answers'
    end
    title
  end

  def current_user
    session[:user]
  end

  def date_to_s date
    d = date.strftime "%d %B %Y"
    d = d[1,d.size-1] if d[0,1] == '0'
    d = date.strftime("%A") + ' ' + d
    d
  end

 def inside_layout(layout, &block)
    @template.instance_variable_set("@content_for_layout", capture(&block))

    layout = layout.include?("/") ? layout : "layouts/#{layout}" if layout
    buffer = eval("_erbout", block.binding)
    buffer.concat(@template.render_file(layout, true))
  end

  def format_date date
    text = date.strftime "%d %b %Y"
    text = text[1..(text.size-1)] if text.size > 0 and text[0..0] == '0'
    text
  end

  def about_title about
    if about
      about.full_name + ': ' + about.class.to_s.gsub(/([a-z])([A-Z])/, '\1 \2') + ': NZ Parliament '
    else
      'Parliamentary Debates: '
    end
  end

  def portrait mp, new=false
    if mp.image.blank?
      if mp.img.blank?
        if mp.member && mp.member.image
          src = mp.member.image
        else
          src = nil
        end
      else
        src = mp.img
      end
    else
      src = mp.image
    end
    src ? image_tag('mps/'+src, :size => '49x59', :class => 'portrait', :alt => mp.last) : ''
  end

  def link_to_recent_debate debate, include_date=false
    if (debate.is_a? BillDebate)
      text = debate.sub_debate.name
    elsif (debate.is_a? SubDebate and !debate.is_a?(OralAnswer))
      text = debate.parent.name + ' <br /> ' + debate.name
    elsif debate.is_a? OralAnswer
      text = debate.title_name
    elsif debate.instance_of?(ParentDebate) && debate.sub_debate
      text = debate.name + ' - ' + debate.sub_debate.name
    else
      text = debate.name
    end
    url = get_url(debate)
    date = include_date ? %Q[<span class="inform_date">#{format_date(debate.date)}</span>] : ''
    link_to(text, url) + ' ' + date
  end

  def link_to_debate debate, show_status=false, show_date=false, show_parent=true
    date = show_date ? ' ' + format_date(debate.date) : ''

    if show_parent && debate.is_a?(SubDebate) && !debate.is_a?(OralAnswer)
      text = debate.parent.name + ' - ' + debate.name
    elsif debate.instance_of?(ParentDebate) && debate.sub_debate
      text = debate.name + ' - ' + debate.sub_debate.name
    else
      text = debate.name
    end

    url = get_url(debate)
    publication_status = (show_status ? status(debate) : '')
    link_to(text, url) + publication_status + date
  end

  def contribution_url contribution, term=nil
    anchor_name = if term
                    paragraph_id(contribution.html, term, contribution.prefixed_anchor)
                  else
                    contribution.prefixed_anchor
                  end
    get_url(contribution.debate)+'#'+anchor_name
  end

  def link_to_contribution text, contribution, term=nil, class_name=nil
    link_to(text, contribution_url(contribution, term), :class=>class_name)
  end

  def link_to_about hash, about, about_type
    link = ''
    if about
      full_name = about.full_name
      full_name = (full_name[0,70]+'...').gsub(/\s[A-Za-z0-9]*\.\.\./, ' ...') if full_name.length > 70
      show_url = symbolize2 'show_', about_type, '_url'

      xhash = {}
      xhash[:committee_url] = hash[:committee_url] if hash.has_key? :committee_url
      xhash[:bill_url] = hash[:bill_url] if hash.has_key? :bill_url
      xhash[:portfolio_url] = hash[:portfolio_url] if hash.has_key? :portfolio_url
      link = link_to(full_name, send(show_url, xhash))
    end
    link
  end

  def get_url_from_hash debate_id_hash
    if debate_id_hash.has_key? :portfolio_url
      show_portfolio_debate_url(debate_id_hash)
    elsif debate_id_hash.has_key? :committee_url
      show_committee_debate_url(debate_id_hash)
    elsif debate_id_hash.has_key? :bill_url
      show_bill_debate_url(debate_id_hash)
    elsif debate_id_hash[:url_slug].blank?
      show_debates_on_date_url(debate_id_hash)
    else
      show_debate_url(debate_id_hash)
    end
  end

  def link_to_hansard text, debate
    if debate.publication_status == 'U'
      date = debate.date.to_s.gsub('-','')
      link_to(text, debate.source_url,  :rel=>"nofollow")
    else
      date = debate.date.to_s.gsub('-','_')
      link_to(text, debate.source_url, :rel=>"nofollow")
    end
  end

  def url_for_portfolio portfolio
    show_portfolio_url(:portfolio_url => portfolio.url)
  end


  def url_for_debate debate
    get_url(debate)
  end

  def url_for_mp mp
    show_mp_url(:name => mp.id_name)
  end

  def url_for_party party
    if party.short == 'Independent'
      nil
    else
      show_party_url(:name => party.id_name)
    end
  end

  def url_for_committee committee
    show_committee_url(:committee_url => committee.url)
  end

  def url_for_organisation organisation
    show_organisation_url(:name => organisation.slug)
  end

  def url_for_bill bill
    show_bill_url(:bill_url => bill.url)
  end

  def percent number
    sprintf('%.1f', number*100)
  end

  def portfolio_pie_chart_url size, title
    name_to_count = Portfolio.name_to_questions_asked_count
    name_to_count = name_to_count.sort{|a,b|a[1]<=>b[1]}
    total = name_to_count.collect{|x| x[1]}.sum.to_f

    names = []
    counts = []
    other = 0

    name_to_count.each do |name_and_count|
      count = name_and_count[1]
      unless count == 0
        if (fraction = count/total) > 0.015
          name = name_and_count[0].sub(' ','%20').sub('Development','Develop.')
          names  << "#{name} #{percent(fraction)}%"
          counts << percent(fraction)
        else
          other += count
        end
      end
    end

    names.insert 0, "Other portfolios #{percent(other/total)}%"
    counts.insert 0, percent(other/total)

    "http://chart.apis.google.com/chart?cht=p&chco=ffebcc,ff9900&chs=#{size}&chd=t:#{counts.join(',')}&chl=#{names.join('|')}&chtt=#{title}"
  end


  # .portfolio_pie_chart
    # %map{ :name=>"portfolios_image_map" }
      # - @portfolios_image_map_areas.each do |area|
        # %area{ :shape=>"rect", :coords => area.coords, :href => area.url, :alt => area.alt }
    # = portfolio_pie_chart
  def portfolio_pie_chart
    size = '660x240'
    title = "Oral Questions to Ministers — November 2005 to #{Date.today.strftime "%B %Y"} |[source: TheyWorkForYou.co.nz]"
    image_tag(portfolio_pie_chart_url(size, title), :usemap => "#portfolios_image_map", :size => size, :class => 'pie_chart', :alt => "Pie chart of #{title}")
  end

  def link_to_portfolio portfolio
    link_to portfolio.portfolio_name, url_for_portfolio(portfolio)
  end

  def link_to_mp mp
    link_to mp.full_name, url_for_mp(mp)
  end

  def party_logo_small party, polls=nil
    if party.logo
      if polls
        factor = polls * 6
        height = [30 * factor, 30].min.to_i
        if height < 10
          ''
        else
          width = [60 * factor, 60].min.to_i
          image_tag('parties/'+party.logo, :class => 'logo_small', :alt => "Logo for #{party.name}", :size=>"#{width}x#{height}")
        end
      else
        image_tag('parties/'+party.logo, :class => 'logo_small', :alt => "Logo for #{party.name}", :size=>'60x30')
      end
    else
      ''
    end
  end

  def party_logo party
    if party.logo
      image_tag('parties/'+party.logo, :class => 'logo', :alt => "Logo for #{party.name}", :size=>'120x60')
    else
      ''
    end
  end

  def link_to_party party, name=nil
    if party.short == 'Independent'
      'Independent'
    else
      name = party.short unless name
      link_to name, url_for_party(party)
    end
  end

  def link_to_committee committee
    link_to committee.full_committee_name, url_for_committee(committee)
  end

  def link_to_organisation organisation
    link_to organisation.name, url_for_organisation(organisation)
  end

  def link_to_bill bill
    link_to bill.bill_name, url_for_bill(bill)
  end

  def link_to_business_item business_item
    if business_item.is_a? Bill
      link_to_bill business_item
    else
      raise 'unhandled link_to_business_item for ' + business_item.class.name
    end
  end

  def link_to_evidence submission
    file_name = submission.evidence_url.split('/').last
    if file_name.size > 30
      file_name = file_name[0..20]+'...'+file_name[-9,9]
    end

    if submission.submitter
    else
      file_name = file_name.split('.')[0].tr('a-z','-') + '.' + file_name.split('.')[1]
    end
    link_to(file_name, submission.evidence_url, :rel=>"nofollow")
  end

  def link_to_user user
    if (current_user and user == current_user)
      link_to '<strong>you</strong>', user_home_url(:user_name => user.login)
    else
      link_to user.login, user_home_url(:user_name => user.login)
    end
  end

  def tracked_item_list t
    if t.users.size == 2
      # '1 other'
      '1'
    elsif t.users.size > 1
      # %Q[#{t.users.size - 1} others]
      %Q[#{t.users.size - 1}]
    else
      '0'
    end
  end

  def tracker_list trackings
    if trackings
      trackings.collect {|t| link_to_user t.user}.join(', ')
    else
      ''
    end
  end

  def percentage nominator, denominator
    number_to_percentage(nominator.to_f / denominator * 100, :precision => 1)
  end

  def symbolize2 prefix, type, suffix
    (prefix+type.to_s.downcase+suffix).to_sym
  end

  def get_url debate
    if debate.is_a? OralAnswer
      if debate.about_type == Portfolio.name
        show_portfolio_debate_url(debate.id_hash)
      elsif (debate.about_type == Bill.name && debate.about_id)
        show_bill_debate_url(debate.id_hash)
      elsif debate.about_type == Committee.name
        show_committee_debate_url(debate.id_hash)
      else
        show_debate_url(debate.id_hash)
      end
    elsif debate.is_a? OralAnswers and debate.sub_debates.size > 0
      get_url debate.sub_debates.sort_by(&:debate_index)[0]
    elsif (debate.is_a? SubDebate and debate.about_type == Bill.name)
      show_bill_debate_url(debate.id_hash)
    elsif (debate.is_a?(BillDebate) && debate.sub_debate.about_id)
      show_bill_debate_url(debate.sub_debate.id_hash)
    elsif debate.is_a?(ParentDebate)
      show_debate_url(debate.sub_debate.id_hash)
    else
      show_debate_url(debate.id_hash)
    end
  end

  def status debate
    case debate.publication_status
      when 'F'
        ''
      when 'A'
        ' (advance)'
      when 'U'
        ' (uncorrected)'
    end
  end

  def bill_type bill
    case bill.class.to_s
      when 'GovernmentBill'
        'Government bill'
      when 'MembersBill'
        "Member's bill"
      when 'PrivateBill'
        'Private bill'
      when 'LocalBill'
        'Local bill'
      else
        ''
    end
  end

  def link_to_remote_contribution text, contribution, term, expand
    link_to_remote(text,
        :update => contribution.id,
        :method => 'get',
        :url => {:controller => 'debates', :action => 'contribution_match', :id => contribution.id, :term => term.to_s, :expand => expand})
  end

  def contribution_title_link contribution
    debate = contribution.debate
    label = "<strong>#{debate.title_name ' - '}</strong>"
    link = link_to_contribution(label, contribution)
    if debate.contributions.size == 1 || debate.contributions.index(contribution) == 0
      link = link.sub(/(#[^'^"]+)/, '')
    end
    %Q[#{link} <small>(#{ format_date(contribution.debate.date) })</small>]
  end

  def contribution_summary contribution, expand, show_mp_name=false
    text = '<p>'
    if show_mp_name
      text += %Q[#{contribution.mp.full_name}]
    else
      text += %Q[<i>#{ contribution.class.to_s.sub('Subs','').sub('Sup','') }</i>]
    end
    paragraphs = contribution.text.split('</p>')
    first_paragraph = paragraphs.first.sub('<p>','').gsub('&quote;','"')
    if paragraphs.size > 1 || first_paragraph.size > 360
      if expand == 'false'
        collapsed_text = first_paragraph[0..259].gsub(/ [A-Za-z0-9]*$/, '')
        if collapsed_text.include?('<i>')
          unless collapsed_text.include?('<//i>')
            collapsed_text += '</i>'
          end
        end
        text += %Q[ #{link_to_remote_contribution('expand', contribution, nil, 'true')}: "#{ collapsed_text} ..."]
      else
        text += %Q[ #{link_to_remote_contribution('collapse', contribution, nil, 'false')}: "#{ contribution.text.sub('<p>','').gsub('&quote;','"').chomp('</p>')}"]
      end
    else
      text += %Q[: "#{ first_paragraph }"]
    end
    text.gsub!('<em>','')
    text.gsub!('</em>','')
    text += '</p>'
  end

  def result_summary pages, items, count
    offset = pages.current.offset
    from = offset+1
    to = offset+items.length

    if from == 1 and to == count
      ''
    else
      %Q[ (#{from}-#{to} out of #{count})]
    end
  end

  def paragraph_id text, term, default
    id = default
    match = false
    paragraphs = text.split("<p id=")

    titlecase = term.titlecase

    paragraphs.each do |p|
      if p.include?(term) || p.include?(titlecase)
        index = p.index('>')
        if index
          id = p.slice(1, index - 2)
          match = true
          break
        end
      end
    end

    unless match
      terms = term.split
      if terms.length > 0
        titlecase = terms[0].titlecase

        paragraphs.each do |p|
          if p.include?(terms[0]) || p.include?(titlecase)
            id = p.slice(1, p.index('>') - 2)
            break
          end
        end
      end
    end
    id.chop! if id[id.length-1,1] == 'a'
    id
  end

  def excerpts text, term, part_match=true
    text = text.gsub(/<p id='[\d\.]*[a-z]*'>/, ' ').gsub('<p>',' ').gsub('</p>',' ').gsub('<i>','').gsub('</i>','')
    excerpts = nil

    if text.include? term
      text = tidy_excerpt(text, term, 120)
      excerpts = highlight(text, term)
    elsif text.include? term.titlecase
      text = tidy_excerpt(text, term.titlecase, 120)
      excerpts = highlight(text, term.titlecase)
    elsif text.include? term.upcase
      text = tidy_excerpt(text, term.upcase, 120)
      excerpts = highlight(text, term.titlecase)
    elsif (latin = text.to_latin.to_s) && latin.include?(term)
      index = latin.chars.index(term)
      unicode = text.chars[index, term.length]
      text = tidy_excerpt(latin, term, 120)
      excerpts = highlight(text, term).gsub(term, unicode)
    elsif part_match
      terms = term.split
      terms.delete_if { |word| IGNORE.include? word }
      count = 0
      terms.each { |term| count += 1 if text.include?(term) }

      char_count = (([1,12-(count*2)].max / 12.0) * 120).to_i #/
      texts = []

      terms.each do |term|
        if !add_term(text, texts, char_count, term)
          if !add_term(text, texts, char_count, term.downcase)
            add_term text, texts, char_count, term.titlecase
          end
        end
      end

      terms.each do |term|
        texts = texts.collect do |text|
          if text.include?(' '+term) || text.include?(' '+term.titlecase) || text.include?(' '+term.downcase)
            highlight(text, ' '+term)
          else
            text
          end
        end
      end
      excerpts = texts.join("<br></br>")
    else
      excerpts = ''
    end

    excerpts
  end

  def tidy_excerpt text, term, chars
    text = excerpt text, term, chars
    text.gsub(/\.\.\.[A-Za-z0-9,\.\?']*[ -]/, '... ').gsub(/ [A-Za-z0-9]*\.\.\./, ' ...') # /
  end

  def add_term text, texts, char_count, term
    present = text.include?(' '+term)
    texts << tidy_excerpt(text, ' '+term, char_count) if present
    present
  end

  IGNORE = ['and', 'the', 'is', 'of']

  def highlights text, term
    if term
      terms = term.split
      terms.delete_if { |word| IGNORE.include? word }
      terms.each do |term|
        if text.include?(' '+term) || text.include?(' '+term.titlecase) || text.include?(' '+term.downcase)
          text = highlight(text, ' '+term)
        end
      end
    end
    text
  end

  def debate_name name, debates
    if debates.nil?
      if name == 'Committee of the whole House: Order of the day for committal discharged'
        'Committee of the whole House'
      elsif name == 'Consideration of report: Order of the day for consideration of report discharged'
        'Consideration of report'
      elsif name == 'Second reading: Order of the day for second reading discharged'
        'Second reading'
      elsif name == 'First reading: Order of the day for first reading discharged'
        'First reading'
      else
        name
      end
    elsif debates.size == 1
      link_to(debates.first.name.sub('Readings','Reading'), get_url(debates.first))
    else
      debates.first.name.sub('Readings','Reading')
    end
  end

  def debate_last_date date, debates
    if debates.nil?
      date.to_s
    else
      debates.first.date.to_s
    end
  end

  def vote_cast_by_party_text party, votes_cast, use_short_name=false
    if votes_cast[0].mp
      if votes_cast[0].vote.is_a? PartyVote
        party_name = party.short == 'Independent' ? party.short : link_to(party.short, show_party_url(:name => party.id_name), :class=>'vote_caster')
        cast_count = votes_cast.inject(0) {|count,vote| count += vote.cast_count}
        if use_short_name
          party_name = party_name.sub('Independent','indep.')
          names = votes_cast.collect(&:vote_label).join(', ')
        else
          names = (render :partial => 'debates/party_vote_cast', :collection => votes_cast).chomp("\n").chomp(",")
        end
        %Q[#{party_name} #{cast_count} (#{names})]
      else
        link_to(votes_cast[0].vote_label, show_mp_url(:name => votes_cast[0].mp.id_name))
      end
    else
      if use_short_name
        party_name = party.short.sub(' Party','').sub('Progressive','Progres.').sub('Future','F.')
      else
        party_name = party.short == 'Independent' ? party.short : link_to(votes_cast[0].vote_label, show_party_url(:name => party.id_name), :class=>'vote_caster')
      end
      %Q[#{party_name} #{votes_cast[0].cast_count.to_s}]
    end
  end

end
