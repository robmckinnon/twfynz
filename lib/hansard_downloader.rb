require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'fileutils'

class HansardDownloader

  def download downloading_uncorrected, update_of_persisted_files_table, download_date=nil, suppress_git_push=false
    @check_for_final = (!update_of_persisted_files_table)
    @download_date = download_date
    @downloading_uncorrected = downloading_uncorrected

    finished = false
    index_page = 0
    debates = debates_in_index(index_page)

    while debates.size > 0 && !finished
      finished = download_debates(debates)
      index_page = index_page.next
      debates = debates_in_index(index_page)

      if (@check_for_final && debates.size > (@downloading_uncorrected ? 0 : 2))
        first_debate = @downloading_uncorrected ? debates.first : debates[2]
        if already_saved?(first_debate) && already_saved?(debates.last)
          finished = true
        end
      end
    end

    if suppress_git_push
      puts 'suppressing git push'
    else
      PersistedFile.set_all_indexes_on_date
      PersistedFile.git_push
    end
  end

  def unload_date date, publication_status
    delete_debates date, publication_status
    records = PersistedFile.find_all_by_debate_date_and_publication_status(date, publication_status)
    puts 'setting ' + records.size.to_s + ' persisted file records to "unpersisted"'
    records.each {|record| record.persisted = false; record.save!}
  end

  def redownload_date date
    data_path = File.join(PersistedFile.data_path, date.strftime('%Y/%m/%d'))

    if (to_delete = get_directory_to_delete(data_path))
      puts "redownloading: #{date}"
      publication_status = to_delete[0..0].upcase

      original_directory, backup = move_original_download(data_path, to_delete, date)
      delete_debates(date, publication_status)
      records_size = delete_records(date, publication_status)

      HansardDownloader.new.download((to_delete == 'uncorrected'),
        (update_of_persisted_files_table=true), date, (suppress_git_push = true) )

      warn_if_problem original_directory, date, publication_status, backup, records_size
    else
      puts 'no directory found to redownload at: ' + data_path
    end
  end

  protected

    def move_original_download data_path, to_delete, date
      original = File.join data_path, to_delete
      backup = original + '_' + Date.today.strftime('%Y_%m_%d')
      puts 'moving ' + original + ' to ' + backup
      FileUtils.move original, backup
      return original, backup
    end

    def delete_debates date, publication_status
      debates = Debate.find_all_by_date_and_publication_status(date, publication_status)
      puts "found: #{debates.size} for #{date} #{publication_status}"
      puts "destroying #{debates.size} debates" if debates
      debates.each { |debate| debate.destroy }
    end

    def delete_records date, publication_status
      records = PersistedFile.find_all_by_debate_date_and_publication_status(date, publication_status)
      records_size = records.size
      puts "destroying #{records_size} persisted file records" if records
      records.each { |record| record.destroy }
      records_size
    end

    def warn_if_problem original, date, publication_status, backup, original_records_size
      if File.exists?(original)
        records = PersistedFile.find_all_by_debate_date_and_publication_status(date, publication_status)
        if records.size == 0
          raise "expected #{original_records_size} new rows to be in persisted_files, but they are not there! backup is: #{backup}"
        elsif records.size != original_records_size
          raise "expected #{original_records_size} new rows to be in persisted_files, but redownloaded #{records.size}, manual fix required!"
        else
          puts 'created ' + records.size.to_s + ' persisted file records; to load use rake kiwimp:load_hansard'
        end
      else
        raise 'original directory has not redownloaded, backup is: ' + backup
      end
    end

    def get_directory_to_delete data_path
      directories = Dir.glob(data_path+'/*').collect do |f|
        f.split('/').last
      end
      if directories.include? 'final'
        'final'
      elsif directories.include? 'advance'
        'advance'
      elsif directories.include? 'uncorrected'
        'uncorrected'
      else
        nil
      end
    end

    def open_index_page page
      if @downloading_uncorrected
        url = 'http://www.parliament.nz/en-NZ/PB/Business/QOA/Default.htm?p='+page.to_s
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
          # puts debate.inner_text
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
          name.include?('Parliamentary Debates (Hansard)') ||
          debate_date(debate) == Date.new(2009,5,17) ||
          debate_date(debate) == Date.new(2009,5,14)
    end

    def ignore_old_content date
      ignore = date <= Date.new(2009,2,1)
      # puts "ignoring older content for now #{date.to_s}" if ignore
      ignore
    end

    def continue_until_we_find_date date
      continue = @download_date && (date > @download_date)
      puts "ignoring #{date}, continuing until we find #{@download_date}" if continue
      continue
    end

    def past_date_we_wanted date
      past = @download_date && (date < (@download_date - 1))
      puts "past #{@download_date}, finished" if past
      past
    end

    def past_date_we_wanted_continue_for_one_more_day date
      past = @download_date && (date == (@download_date - 1))
      puts "past #{@download_date}, continuing for one more day" if past
      past
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
        # puts "persisted_file exists #{persisted_file.inspect}"
        PersistedFile.add_if_missing persisted_file

      elsif @downloading_uncorrected
        finished = download_this_debate persisted_file

      else
        persisted_file.set_publication_status('advance')
        advance_exists = persisted_file.exists?

        # if advance_exists && (!@check_for_final || @download_date)
          # puts 'persisted_file exists'
          # PersistedFile.add_if_missing persisted_file
        # else
          if advance_exists
            puts "checking status: #{persisted_file.parliament_url}"
            persisted_file.set_publication_status('final')
          end
          finished = download_this_debate persisted_file
        # end
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
        if status.nil?
          puts "cannot determine status from contents: #{persisted_file.parliament_url}"
        end

        persisted_file.set_publication_status(status)

        if @downloading_uncorrected && status != 'uncorrected'
          finished = true # finished downloading uncorrected oral answer files
        elsif persisted_file.exists?
          PersistedFile.add_if_missing persisted_file

        elsif persisted_file.others_exists_on_date?
          puts 'need to reload day, coz of: ' + persisted_file.parliament_url

          redownload_date persisted_file.debate_date
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
      if contents.include?('[Advance Copy') || contents.include?('[Advance copy')
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
