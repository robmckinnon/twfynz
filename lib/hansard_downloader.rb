require 'rubygems'
require 'open-uri'
require 'hpricot'

class HansardDownloader

  def download download_directory, downloading_uncorrected, update_of_persisted_files_table, download_date=nil
    @check_for_final = (!update_of_persisted_files_table)
    @download_date = download_date
    @downloading_uncorrected = downloading_uncorrected
    @base_path = download_directory
    index = 0
    doc = open_index index
    puts "opened: #{index}"
    debates = (doc/'h4/a')
    finished = false

    while (debates.size > 0 and !finished)
      if debates.size == 0
        finished = true
      end
      debates.each do |debate|
        name = debate.inner_text
        name.sub!(', ','') if name.starts_with? ', '
        unless (finished or
            (name == 'List of questions for oral answer') or
            (name == 'Daily debates') or
            (name == 'Speeches') or
            name.include?('Parliamentary Debates (Hansard)'))
          finished = download_debate debate
        end
      end
      index = index.next
      doc = open_index index
      debates = (doc/'h4/a')

      if (@check_for_final and debates.size > (@downloading_uncorrected ? 0 : 2))
        first_debate = @downloading_uncorrected ? debates.first : debates[2]
        if (already_saved?(first_debate) and already_saved?(debates.last))
          finished = true
        end
      end
    end
  end

  protected

    def open_index index
      if @downloading_uncorrected
        url = 'http://www.parliament.nz/en-NZ/PB/Debates/QOA/Default.htm?p='+index.to_s
      else
        url = 'http://www.parliament.nz/en-NZ/PB/Debates/Debates/Default.htm?p='+index.to_s
      end

      puts 'opening: ' + url
      Hpricot open(url)
    end

    def already_saved? debate
      date = get_date debate
      name = debate.attributes['href'].split('/').last
      File.exists? file_name(date, 'final', name)
    end

    def check_persisted_files filename, date, parliament_name, url
      name = filename.sub(@base_path,'')
      record = PersistedFile.find_by_file_name(name)

      unless record
        time = File.new(filename).ctime
        download_date = Date.new(time.year, time.month, time.day).to_s
        record = PersistedFile.new ({
            :debate_date => date,
            :publication_status => publication_status(filename),
            :oral_answer => @downloading_uncorrected,
            :file_name => name,
            :parliament_name => parliament_name,
            :parliament_url => url,
            :downloaded => true,
            :download_date => download_date
        })
        puts "adding #{name} to persisted_files"
        record.save!
      end
    end

    def download_debate debate
      url = 'http://www.parliament.nz'+debate.attributes['href']
      date = get_date debate

      if @download_date
        if date > @download_date
          # puts "we're continuing until we find date"
          return false
        elsif date < (@download_date - 1)
          # puts "we're past the date we wanted"
          return true
        elsif date == (@download_date - 1)
          # puts "we might be past the date we wanted, continue for one more day"
          return false
        end
      end

      name = url.split('/').last

      filename = file_name(date, (@downloading_uncorrected ? 'uncorrected' : 'final'), name)

      parliament_name = debate.inner_text
      parliament_name.sub!(', ','') if parliament_name.starts_with? ', '

      if File.exists? filename
        check_persisted_files filename, date, parliament_name, url
      else
        advance_filename = file_name(date, 'advance', name)
        if @check_for_final
          puts 'checking status: ' + url if (!@downloading_uncorrected and File.exists?(advance_filename))

        elsif (File.exists?(advance_filename) and not(@download_date))
          check_persisted_files advance_filename, date, parliament_name, url
          return false # ie don't check for final file
        end

        page = nil
        open(url) { |io| page = io.read }

        if page.include? 'Server Error'
          record = PersistedFile.new ({
              :debate_date => date,
              :downloaded => false,
              :oral_answer => @downloading_uncorrected,
              :parliament_name => parliament_name,
              :parliament_url => url
          })
          record.save!
          return false
        end

        filename = directory(page, date)+'/'+name

        if (@downloading_uncorrected and !filename.include?('uncorrected'))
          return true # finished downloading uncorrected oral answer files
        end

        if File.exists? filename
          check_persisted_files filename, date, parliament_name, url
        else
          record = PersistedFile.new ({
              :debate_date => date,
              :publication_status => publication_status(filename),
              :oral_answer => @downloading_uncorrected,
              :file_name => filename.sub(@base_path,''),
              :parliament_name => debate.inner_text,
              :parliament_url => url
          })
          puts 'writing: ' + record.file_name
          File.open(filename, 'w') do |file|
            file.write(page)
            record.downloaded = true
            record.download_date = Date.today
          end
          record.save!
        end
      end

      return false
    end

    def get_date debate
      name = debate.attributes['href'].split('/').last
      if (match = /Hans(D|Q)_(\d\d\d\d)(\d\d)(\d\d)/.match name)
        date = Date.new(match[2].to_i,match[3].to_i,match[4].to_i)
        date
      else
        raise "can't figure out date from url " + name
      end
    end

    def file_name(date, status, name)
      @base_path + date.strftime('%Y/%m/%d')+'/'+status+'/'+name
    end

    def publication_status filename
      if filename.include? 'advance'
        'A'
      elsif filename.include? 'uncorrected'
        'U'
      elsif filename.include? 'final'
        'F'
      end
    end

    def directory page, date
      if page.include? '[Advance Copy'
        make_directory date, 'advance'
      elsif page.include? '[Uncorrected transcript'
        make_directory date, 'uncorrected'
      elsif page.include? '[Volume'
        make_directory date, 'final'
      else
        nil
      end
    end

    def make_directory date, publication_status
      make @base_path
      make @base_path + date.strftime('%Y')
      make @base_path + date.strftime('%Y/%m')
      make @base_path + date.strftime('%Y/%m/%d')
      make @base_path + date.strftime('%Y/%m/%d')+'/'+publication_status
    end

    def make directory
      Dir.mkdir directory unless File.exists? directory
      directory
    end

end
