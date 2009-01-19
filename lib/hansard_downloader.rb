require 'rubygems'
require 'open-uri'
require 'hpricot'

class HansardDownloader

  def download downloading_uncorrected, update_of_persisted_files_table, download_date=nil
    @check_for_final = (!update_of_persisted_files_table)
    @download_date = download_date
    @downloading_uncorrected = downloading_uncorrected

    finished = false
    index_page = 0
    debates = debates_in_index index_page

    while (debates.size > 0 and !finished)
      finished = download_debates(debates)
      index_page = index_page.next
      debates = debates_in_index index_page

      if (@check_for_final and debates.size > (@downloading_uncorrected ? 0 : 2))
        first_debate = @downloading_uncorrected ? debates.first : debates[2]
        if (already_saved?(first_debate) and already_saved?(debates.last))
          finished = true
        end
      end
    end
  end

  protected

    def open_index_page page
      if @downloading_uncorrected
        url = 'http://www.parliament.nz/en-NZ/PB/Debates/QOA/Default.htm?p='+page.to_s
      else
        url = 'http://www.parliament.nz/en-NZ/PB/Debates/Debates/Default.htm?p='+page.to_s
      end
      puts 'opening: ' + url
      Hpricot open(url)
    end

    def debates_in_index page
      doc = open_index_page page
      debates = (doc/'h4/a')
      debates
    end

    def already_saved? debate
      date = debate_date(debate)
      PersistedFile.exists?(date, 'final', debate_name(debate)) || (date <= Date.new(2008,12,1))  # ignoring older content for now
    end

    def download_debates debates
      finished = false
      debates.each do |debate|
        name = debate.inner_text
        name.sub!(', ','') if name.starts_with? ', '
        unless (finished or
            (name == 'List of questions for oral answer') or
            (name == 'Daily debates') or
            (name == 'Speeches') or
            name.include?('Parliamentary Debates (Hansard)'))
          finished = download_debate(debate)
        end
      end
      finished
    end

    def download_debate debate
      date = debate_date(debate)
      finished =  if (date <= Date.new(2008,12,1))  # ignoring older content for now
                    false
                  elsif @download_date
                    if date > @download_date  # "we're continuing until we find date"
                      false
                    elsif date < (@download_date - 1)  # "we're past the date we wanted"
                      true
                    elsif date == (@download_date - 1)  # "we might be past the date we wanted, continue for one more day"
                      false
                    else
                      continue_download_debate date, debate
                    end
                  else
                    continue_download_debate date, debate
                  end
      finished
    end

    def continue_download_debate date, debate
      url = debate_url(debate)
      name = debate_name(debate)
      parliament_name = parliament_name(debate)
      download_if_new date, url, name, parliament_name
    end

    def download_if_new date, url, name, parliament_name
      status = (@downloading_uncorrected ? 'uncorrected' : 'final')
      finished = false

      if PersistedFile.exists?(date, status, name)
        PersistedFile.add_if_missing date, status, name, parliament_name, url, @downloading_uncorrected

      elsif PersistedFile.exists?(date, 'advance', name)
        if !@check_for_final && !@download_date # ie don't check for final file
          PersistedFile.add_if_missing date, 'advance', name, parliament_name, url, @downloading_uncorrected
        else
          puts "checking status: #{url}" unless @downloading_uncorrected
          finished = download_this_debate date, url, name, parliament_name
        end
      else
        finished = download_this_debate date, url, name, parliament_name
      end

      finished
    end

    def download_this_debate date, url, name, parliament_name
      contents = debate_contents(url)
      finished = false

      if contents.include? 'Server Error'
        PersistedFile.add_non_downloaded date, parliament_name, url, @downloading_uncorrected
      else
        status = publication_status_from(contents)
        if @downloading_uncorrected && status != 'uncorrected'
          finished = true # finished downloading uncorrected oral answer files
        elsif PersistedFile.exists?(date, status, name)
          PersistedFile.add_if_missing date, status, name, parliament_name, url, @downloading_uncorrected
        else
          PersistedFile.add_new date, status, name, parliament_name, url, @downloading_uncorrected, contents
        end
      end
      finished
    end

    def debate_contents url
      contents = nil
      open(url) { |io| contents = io.read }
      contents
    end

    def debate_url debate
      'http://www.parliament.nz'+debate.attributes['href']
    end

    def debate_name debate
      debate.attributes['href'].split('/').last
    end

    def parliament_name debate
      parliament_name = debate.inner_text
      parliament_name.sub!(', ','') if parliament_name.starts_with? ', '
      parliament_name
    end

    def debate_date debate
      name = debate_name debate
      if (match = /Hans(D|Q)_(\d\d\d\d)(\d\d)(\d\d)/.match name)
        Date.new($2.to_i, $3.to_i, $4.to_i)
      else
        raise "can't figure out date from url " + name
      end
    end

    def publication_status_from contents
      if contents.include? '[Advance Copy'
        'advance'
      elsif contents.include? '[Uncorrected transcript'
        'uncorrected'
      elsif contents.include? '[Volume'
        'final'
      else
        nil
      end
    end

end
