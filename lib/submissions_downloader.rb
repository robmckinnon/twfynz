require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'uri'

class SubmissionsDownloader

  def self.submission_download index = 0
    while (continue = self.download_page(index))
      index = index.next
    end
  end

  def self.open_page page_number
    url = "http://www.parliament.nz/en-NZ/PB/SC/Documents/Evidence/Default.htm?p=#{page_number.to_s}"
    puts 'downloading '+url
    Hpricot open(url)
  end

  def self.download_page page_number
    doc = open_page(page_number)
    committees = find_committees doc
    found_submissions = committees.size > 0
    create_submissions committees, doc if found_submissions
    found_submissions
  end

  def self.find_committees doc
    (doc/'td[@class="attr attrauthor"]/text()').collect {|c| c.to_s.strip }
  end

  def self.find_dates doc
    (doc/'td[@class="attr attrPublicationDate"]/text()').collect do |d|
      date = d.to_s.strip               # e.g. 17 Sep 07
      date = date[0..6]+'20'+date[7..9] # e.g. 17 Sep 2007
      Date.parse(date).to_s
    end
  end

  def self.find_view_all_url doc
    doc.at('a[@title="View the contents of these documents on one page"]').attributes['href']
  end

  def self.load_details_doc detailed_url
    data = []
    open('http://www.parliament.nz/'+detailed_url) do |f|
      f.readlines.each { |l| data << l unless l.include?('<input type="hidden"') }
    end
    Hpricot data.join("/n")
  end

  def self.find_title_elements doc
    (doc/'div.section/h1')
  end

  def self.find_business_item element
    element.inner_text.to_s.split('–')[0].strip
  end

  def self.find_submitter_text element
    element.inner_text.to_s.split('–')[1].strip
  end

  def self.find_document title_element
    element = title_element.parent.next_sibling.next_sibling
    cite = element.at('cite')
    cite ? cite.parent.attributes['href'].to_s : nil
  end

  def self.find_document_2 title_element
    element = title_element.parent.next_sibling
    cite = element.at('cite')
    cite ? cite.parent.attributes['href'].to_s : nil
  end

  def self.submitter_search_term text
    URI.encode( text[/(^.+) Supp\d+$/i, 1] || text )
  end

  def self.search_results name
    url = "http://www.google.com/search?&q=%22#{submitter_search_term(name)}%22%20site%3Anz"
    results = Hpricot open(url)
  end

  def self.feeling_lucky_url name
    results = (search_results(name) / 'h2.r/a').collect {|a| a.attributes['href']}

    if results.size > 0 && !results.first.starts_with?('http://www.parliament.nz/')
      results.first
    else
      ''
    end
  end

  def self.create_submissions committees, doc
    puts 'found ' + committees.size.to_s + ' submissions'
    dates = find_dates doc
    detailed_url = find_view_all_url doc
    details_doc = load_details_doc detailed_url

    find_title_elements(details_doc).each_with_index do |title, i|
      begin
        document_url = find_document title
      rescue Exception => e
        begin
          document_url = find_document_2 title
        rescue Exception => e
          puts detailed_url + ' ' + title.inner_text
          raise e
        end
      end
      if document_url
        submitter = find_submitter_text title
        business_item = find_business_item title
        submission = Submission.find_by_submitter_name_and_business_item_name(submitter, business_item)

        unless submission
          submission = Submission.new :submitter_name => submitter,
            :submitter_url => nil, # feeling_lucky_url(submitter),
            :business_item_name => find_business_item(title),
            :committee_name => committees[i],
            :date => dates[i],
            :evidence_url => 'http://www.parliament.nz'+document_url,
            :business_item_type => '',
            :business_item_id => 0,
            :is_from_organisation => false,
            :submitter_type => nil,
            :submitter_id => nil
          puts 'saving ' + submitter + ' - ' + business_item
          submission.save!
        end
      end
    end
  end

end
