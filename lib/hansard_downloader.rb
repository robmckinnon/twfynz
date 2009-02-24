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

    PersistedFile.set_all_indexes_on_date

    PersistedFile.git_push
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
        unless finished || ignore_debate?(debate)
          finished = download_debate(debate)
        end
      end
      finished
    end

    def ignore_debate? debate
      name = debate.inner_text
      name.sub!(', ','') if name.starts_with? ', '
      name == 'List of questions for oral answer' ||
          name == 'Daily debates' ||
          name == 'Speeches' ||
          name.include?('Parliamentary Debates (Hansard)')
    end

    def ignore_old_content date
      date <= Date.new(2008,12,1) # ignoring older content for now
    end

    def continue_until_we_find_date date
      @download_date && (date > @download_date)
    end

    def past_date_we_wanted date
      @download_date && (date < (@download_date - 1))
    end

    def past_date_we_wanted_continue_for_one_more_day date
      @download_date && (date == (@download_date - 1))
    end

    def keep_looking date
      ignore_old_content(date) || continue_until_we_find_date(date) || past_date_we_wanted_continue_for_one_more_day(date)
    end

    def download_debate debate
      date = debate_date(debate)
      finished = if keep_looking(date)
                   false
                 elsif past_date_we_wanted(date)
                   true
                 else
                   continue_download_debate(date, debate)
                 end
      finished
    end

    def continue_download_debate date, debate
      persisted_file = PersistedFile.new({
          :debate_date => date,
          :oral_answer => @downloading_uncorrected,
          :parliament_name => parliament_name(debate),
          :parliament_url => debate_url(debate)
      })
      persisted_file.set_publication_status(@downloading_uncorrected ? 'uncorrected' : 'final')

      download_if_new persisted_file
    end

    def download_if_new persisted_file
      finished = false

      if persisted_file.exists?
        PersistedFile.add_if_missing persisted_file

      elsif @downloading_uncorrected
        finished = download_this_debate persisted_file

      else
        persisted_file.set_publication_status('advance')
        advance_exists = persisted_file.exists?

        if advance_exists && (!@check_for_final || @download_date)
          PersistedFile.add_if_missing persisted_file
        else
          puts "checking status: #{persisted_file.parliament_url}" if advance_exists
          persisted_file.set_publication_status('final')
          finished = download_this_debate persisted_file
        end
      end

      finished
    end

    def download_this_debate persisted_file
      contents = debate_contents(persisted_file.parliament_url)
      finished = false

      if contents.include? 'Server Error'
        PersistedFile.add_non_downloaded persisted_file
      else
        status = publication_status_from(contents)
        persisted_file.set_publication_status(status)

        if @downloading_uncorrected && status != 'uncorrected'
          finished = true # finished downloading uncorrected oral answer files
        elsif persisted_file.exists?
          PersistedFile.add_if_missing persisted_file
        else
          PersistedFile.add_new persisted_file, contents
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
