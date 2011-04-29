require 'open-uri'
require 'yaml'
require 'hpricot'
require 'morph'

class BillProxy

  include Morph

  attr_accessor :name, :type, :reference, :parliament_url

  def initialize url
    step_off = 1
    text = obtain_text url
    while text.nil?
      step_off += 1
      sleep 2 * step_off
      text = obtain_text url
    end

    set_attributes_from_text text
  end

  def obtain_text url
    @url = url
    puts '  downloading ' + url
    self.parliament_url = url

    text = ''
    file = url.tr('/','')
    if File.exists? file
      puts 'reading from cache: ' + file
      File.open(file, 'r') {|f| text = f.read}
    else
      open('http://www.parliament.nz/en-NZ/PB/Legislation/Bills/'+url) do |f|
        text = f.read
      end
      if text[/Oops - there has been an error/]
        text = nil
      else
        puts 'caching: ' + file
        File.open(file, 'w') {|f| f.write text}
      end
    end
    text
  end

  def set_attributes_from_text text
    doc = Hpricot text.gsub('disharged', 'discharged')

    (doc/'th[@scope="row"]').each do |node|
      label = node.inner_text.strip.chomp(':').strip
      value = node.next_sibling.inner_text.strip

      send "data_#{label.gsub(' ','_').sub('(','').sub(')','').downcase}=".to_sym, value
    end

    text.each_line do |line|
      line = line.gsub('disharged', 'discharged')
      process_line line
    end

    set_title_info text
  end

  def create_bill
    attributes = {
      :bill_name => data_title,
      :parliament_url => parliament_url
    }

    attributes[:bill_no] = data_bill_no if respond_to? :data_bill_no
    attributes[:type] = data_type_of_bill.gsub("'",'')+'Bill'

    attributes[:description] = data_info if respond_to? :data_info
    attributes[:act_name] = data_act if respond_to? :data_act
    attributes[:mp_name] = data_member_in_charge if respond_to? :data_member_in_charge
    attributes[:referred_to] = data_referred_to if respond_to? :data_referred_to
    attributes[:bill_change] = data_bill_change if respond_to? :data_bill_change

    populate_dates attributes

    puts '    ' + attributes.inspect

    attributes.delete(:sc_reports_interim_report_interim_report) # temp fix
    attributes.delete(:first_reading_withdrawn) # temp fix

    bill = Object.const_get(attributes[:type]).new(attributes)
    bill.reset_earliest_date

    if bill.earliest_date.nil? && respond_to?(:nzgls_date)
      if bill.bill_change.nil?
        bill.earliest_date = nzgls_date[0..9]
      else
        bill.earliest_date = nzgls_date[0..9]
      end
    end

    bill.valid?
    bill
  end

  def earliest_date
    dates = [introduction, first_reading, second_reading, committee_of_the_whole_house, third_reading, royal_assent].compact.sort
    dates.first
  end

  def nil_value
    nil
  end

  private

    def set_title_info text
      if (match = /<h1>([^<]*)<\/h1>([^<]*)<table class="variablelist"/.match text)
        self.data_title = match[1].squeeze(' ')
        self.data_info = match[2].strip

      elsif (match = /<div class="section"><h1>([^<]*)<\/h1>\s*<p>(.*)<\/p>\s*<table class="variablelist"/.match text)
        self.data_title = match[1].squeeze(' ')
        self.data_bill_change = match[2].strip

      elsif (match = /<div class="section"><h1>([^<]*)<\/h1>\s*(.*)\s*<p>(.*)<\/p>\s*<table class="variablelist"/.match text)
        self.data_title = match[1].squeeze(' ')
        self.data_info = match[2].strip
        self.data_bill_change = match[3].strip

      elsif (match = /<h1>([^<]*)<\/h1>([^<]*)<p>(.*)<\/p>([^<]*)<table class="variablelist"/.match text)
        self.data_title = match[1].squeeze(' ')
        self.data_bill_change = match[3].strip
      end
    end

    def process_line line
      if (match = /<meta name="DC\.([^"]*)" content="([^"]*)"/.match line)
        send "dc_#{match[1].downcase}=".to_sym, match[2]

      elsif (match = /<meta name="NZGLS\.([^"]*)" content="([^"]*)"/.match line)
        send "nzgls_#{match[1].downcase}=".to_sym, match[2]

      elsif (match = /<tr><th scope="row">Committee of the whole House:<\/th><td>Order of the day for committal discharged<\/td><\/tr><tr><th scope="row"><\/th><td>([^<]*)<\/td>/.match line)
        send "data_committal_discharged=".to_sym, match[1]

      elsif (match = /<tr><th scope="row">Consideration of report:<\/th><td>([^<]*)<\/td><\/tr><tr><th scope="row"><\/th><td>order of the day for consideration of report discharged<\/td><\/tr><tr><th scope="row"><\/th><td>([^<]*)<\/td>/.match line)
        send "data_consideration_of_report_discharged=".to_sym, match[2]

      elsif (match = /<tr><th scope="row">Consideration of report:<\/th><td>Order of the day for consideration of report discharged.<\/td><\/tr><tr><th scope="row"><\/th><td>([^<]*)<\/td>/.match line)
        send "data_consideration_of_report_discharged=".to_sym, match[1]

      elsif (match = /<td>Order of the day for interrupted second reading discharged<\/td><\/tr><tr><th scope="row"><\/th><td>([^<]*)<\/td>/.match line)
        send "data_second_reading_discharged=".to_sym, match[1]

      elsif (match = /<td>Order of the day for second reading discharged.<\/td><\/tr><tr><th scope="row"><\/th><td>([^<]*)<\/td>/.match line)
        send "data_second_reading_discharged=".to_sym, match[1]

      elsif (match = /<td>Order of the day for second reading discharged<\/td><\/tr><tr><th scope="row"><\/th><td>([^<]*)<\/td>/.match line)
        send "data_second_reading_discharged=".to_sym, match[1]

      elsif (match = /<td>Order of the day for First reading discharged.<\/td><\/tr><tr><th scope="row"><\/th><td>([^<]*)<\/td>/.match line)
        send "data_first_reading_discharged=".to_sym, match[1]

      elsif (match = /<td>Order of the day for first reading discharged<\/td><\/tr><tr><th scope="row"><\/th><td>([^<]*)<\/td>/.match line)
        send "data_first_reading_discharged=".to_sym, match[1]

      elsif (match = /SC report\(s\):<\/th><td>(.*) \(Interim report\)<\/td><\/tr><tr><th scope="row"><\/th><td>(.*)<\/td>/.match line)
        send "data_sc_reports_interim_report=".to_sym, match[1] # hack for Climate Change (Emissions Trading and Renewable Preference) Bill
        send "data_sc_reports=".to_sym, match[2] # hack for Climate Change (Emissions Trading and Renewable Preference) Bill

      elsif (match = /SC report\(s\):<\/th><td>Discharged from Transport and Industrial Relations Committee 21\/8\/06<\/td><\/tr><tr><th scope="row"><\/th><td>29\/6\/07<\/td>/.match line)
        send "data_sc_reports=".to_sym, '29/6/07' # hack for Minimum Wage (Abolition of Age Discrimination) Amendment Bill, bill_no: 9-2

      elsif (match = /Second reading:<\/th><td>Order of the day for second reading discharged. Referred to Transport and Industrial Relations Committee 30\/8\/06<\/td><\/tr><tr><th scope="row"><\/th><td>25\/7\/07<\/td>/.match line)
        send "data_second_reading=".to_sym, '25/7/07' # hack for Minimum Wage (Abolition of Age Discrimination) Amendment Bill, bill_no: 9-2

      elsif (match = /Committee of the whole House:<\/th><td>(20\/2\/02)<\/td><\/tr><tr><th scope="row"><\/th><td>(13\/3\/02)<\/td><\/tr><tr><th scope="row"><\/th><td>27\/3\/02<\/td>/.match line)
        send "data_committee_of_the_whole_house=".to_sym, '27/3/02' # hack for Shop Trading Hours Act Repeal Act (Abolition of Restrictions) Amendment Bill, bill_no: 272-3

      elsif (match = /Third reading:<\/th><td>Order of the day for third reading discharged. Referred to Commerce Committee 15\/5\/02<\/td>/.match line)
        # hack for Shop Trading Hours Act Repeal Act (Abolition of Restrictions) Amendment Bill, bill_no: 272-3

      elsif (match = /Consideration of report:<\/th><td>Order of the day for consideration of report discharged, re-referred to Commerce Committee 2\/8\/00<\/td><\/tr><tr><th scope="row"><\/th><td>12\/12\/01<\/td><\/tr><tr><th scope="row"><\/th><td>5\/5\/04<\/td><\/tr><tr><th scope="row"><\/th><td>Question that the bill do proceed negatived. 5\/5\/04<\/td>/.match line)
        send "data_consideration_of_report=".to_sym, '5/5/04' # hack for Shop Trading Hours Act Repeal Act (Abolition of Restrictions) Amendment Bill, bill_no: 272-3
      end
    end

    def parse_date value
      ddmmyy = value.split'/'
      day = ddmmyy[0]
      month = ddmmyy[1]
      year = ddmmyy[2]
      day = '0'+day if day.size < 2
      month = '0'+month if month.size < 2
      decade = year[0..0]
      year = '20'+year if decade.to_i < 4
      year = '19'+year if decade.to_i >= 4

      %Q[#{year}-#{month}-#{day}]
    end

    def populate_dates attributes
      populate_date(:data_introduction, attributes)
      populate_date(:data_first_reading, attributes)
      populate_date(:data_submissions_due, attributes)
      populate_date(:data_sc_reports, attributes)
      populate_date(:data_sc_reports_interim_report, attributes)
      populate_date(:data_consideration_of_report, attributes)
      populate_date(:data_committee_of_the_whole_house, attributes)
      populate_date(:data_second_reading, attributes)
      populate_date(:data_third_reading, attributes)
      populate_date(:data_royal_assent, attributes)
      populate_date(:data_committal_discharged, attributes)
      populate_date(:data_consideration_of_report_discharged, attributes)
      populate_date(:data_second_reading_discharged, attributes)
      populate_date(:data_first_reading_discharged, attributes)
      populate_date(:data_second_reading_withdrawn, attributes)
    end

    def populate_date field, attributes
      return unless respond_to? field
      value = send field
      name = field.to_s.sub('data_','')
      date_field = name.to_sym

      if value
        value = value.sub('(','').sub(')','')
        if value.size > 0 and value.size < 9
          attributes[date_field] = parse_date(value)

        elsif value.include? 'negatived'
          negatived = (name + '_negatived').to_sym
          attributes[negatived] = true
          attributes[date_field] = parse_date(value.split(' ').last)

        elsif value.sub('disharged','discharged').downcase.include? 'discharged'
          value.sub!('disharged','discharged')
          discharged = (name + '_discharged').to_sym
          attributes[discharged] = value

        elsif value.include? 'nterim report'
          interim = (name + '_interim_report').to_sym
          attributes[interim] = parse_date(value.split(' ').first)

        elsif value.include?  'ithdrawn'
          withdrawn = (name + '_withdrawn').to_sym
          attributes[withdrawn] = true

        else
          p(name+': '+value) if value
        end
      end
    end

end
