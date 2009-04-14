require 'fileutils'
require 'yaml'

class PersistedFile < ActiveRecord::Base

  before_validation_on_create :default_persisted

  def others_exists_on_date?
    PersistedFile.persisted_version_exists?(debate_date, publication_status)
  end

  class << self

    def persisted_version_exists? date, publication_status_code
      persisted = find_all_by_persisted_and_debate_date_and_publication_status(true, date, publication_status_code)
      !persisted.empty?
    end

    def load_questions
      require File.dirname(__FILE__) + '/../../lib/hansard_parser.rb'
      dates = unpersisted_dates('U')

      dates.each do |date|
        files = unpersisted_files(date, 'U').sort_by(&:file_name)
        load_questions_for files
      end
    end

    def load_questions_for files
      oral_answers = nil
      files.each_with_index do |file, index|
        puts "parsing: #{file.storage_name}"
        parser = HansardParser.new(file.storage_name, file.parliament_url, file.debate_date)
        oral_answers = parser.parse_oral_answer(index+1, oral_answers)
      end
      puts "saving: #{oral_answers.class.name}"
      oral_answers.save!
      files.each { |f| f.do_persist! }
      date = files.first.debate_date
      puts "persisted: #{date}"
      oral_answers.create_url_slugs!
      puts "created url slugs: #{date}"
      Debate.expire_cached_pages date
    end

    def date_after_sept_2005? date
      date.year > 2008 || (date.year == 2008 && date.month > 11)
    end

    def load_debates publication_status, sleep_seconds
      dates = unpersisted_dates(publication_status).select {|d| date_after_sept_2005? d}
      dates.each { |date| load_debates_for_date date, publication_status, sleep_seconds }
    end

    def load_debates_for_date date, publication_status, sleep_seconds=nil
      files = unpersisted_files(date, publication_status).sort_by(&:file_name)
      load_debates_for files, sleep_seconds
    end

    def load_debates_for files, sleep_seconds=nil
      index = 1
      debates = []
      files.each do |file|
        puts "parsing: #{file.storage_name}"
        parser = HansardParser.new(file.storage_name, file.parliament_url, file.debate_date)
        debate = parser.parse(index)

        if debate.is_a?(Array)
          debate_list = debate
          debate_list.each {|d| d.valid?}
          index = debate_list.last.last_debate_index
          debate_list.each {|d| debates << d }
        else
          debate.valid?
          index = debate.last_debate_index if debate.respond_to?(:last_debate_index)
          debates << debate
        end
        index = index.next
        sleep sleep_seconds if sleep_seconds
      end

      debates.each_with_index do |debate, index|
        puts "saving: #{debate.name}"
        begin
          debate.save!
        rescue Exception => e
          debates.each_with_index do |a_debate, a_index|
            a_debate.destroy if a_index < index
          end
          raise e
        end
      end

      files.each { |f| f.do_persist! }
      date = files.first.debate_date
      publication_status = files.first.publication_status
      puts "persisted: #{date}"

      Debate.find_all_by_date_and_publication_status(date,publication_status).sort_by(&:debate_index).each do |debate|
        debate.create_url_slug
        debate.save!
      end
      SubDebate.find_all_by_url_slug(nil).each {|s| s.create_url_slug; s.save!}
      puts "created url slugs: #{date}"
      Debate.expire_cached_pages date
    end

    def load_yaml_index
      Dir.glob("#{storage_path}2*/**/index.yaml").each do |file|
        data = YAML::load_file(file)
        files = data.collect {|d| PersistedFile.new(d) }
        stored = files.first

        if stored.parliament_url
          existing = PersistedFile.find_by_parliament_url_and_publication_status(stored.parliament_url, stored.publication_status)
          if existing && (existing.persisted || existing.debate_date < Date.new(2008,12,1) )
            msg = "#{stored.debate_date} #{stored.publication_status} #{files.size}"
            puts "existing #{msg}"
          else
            if stored.oral_answer
              load_questions_for(files)
            else
              load_debates_for(files)
            end
          end
        end
      end
    end

    def git_push msg="download on #{Date.today.to_s}"
      Dir.chdir storage_path
      puts `git add .`
      puts `git status`
      puts `git commit -m '#{msg}'`
      puts `git push`
    end

    def git_pull
      Dir.chdir storage_path
      puts `git pull`
    end

    def storage_path
      RAILS_ROOT + '/nz-hansard/'
    end

    def data_path
      RAILS_ROOT + '/data/'
    end

    def file_name(date, status, name)
      date.strftime('%Y/%m/%d')+'/'+status+'/'+name
    end

    def file_path(date, status, name)
      data_path + file_name(date, status, name)
    end

    def exists? date, status, name
      File.exists? file_path(date, status, name)
    end

    def publication_status_name status_code
      if status_code[/A/]
        'advance'
      elsif status_code[/U/]
        'uncorrected'
      elsif status_code[/F/]
        'final'
      end
    end

    def publication_status_code status
      if status[/advance/]
        'A'
      elsif status[/uncorrected/]
        'U'
      elsif status[/final/]
        'F'
      end
    end

    def add_new record, contents
      make_directory record.debate_date, record.publication_status_name

      record.file_name = record.make_file_name
      puts 'writing: ' + record.file_name
      filepath = record.make_file_path

      File.open(filepath, 'w') do |file|
        file.write(contents)
        record.downloaded = true
        record.download_date = Date.today
      end
      record.save!
    end

    def add_if_missing record
      debate_date = record.debate_date
      filename = record.make_file_name
      existing = find_by_file_name(filename)

      unless existing
        filepath = record.make_file_path
        time = File.new(filepath).ctime
        download_date = Date.new(time.year, time.month, time.day).to_s

        record.file_name = filename
        record.downloaded = true
        record.download_date = download_date

        puts "adding #{filename} to persisted_files"
        record.save!
      end
    end

    def add_non_downloaded record
      record.downloaded = false
      record.save!
    end

    def make_directory date, publication_status
      make_dir data_path
      make_dir data_path + date.strftime('%Y')
      make_dir data_path + date.strftime('%Y/%m')
      make_dir data_path + date.strftime('%Y/%m/%d')
      make_dir data_path + date.strftime('%Y/%m/%d')+'/'+publication_status
    end

    def make_dir directory
      Dir.mkdir directory unless File.exists? directory
    end

    def set_all_indexes_on_date
      set_indexes_for_status 'U'
      set_indexes_for_status 'A'
      set_indexes_for_status 'F'
    end

    def set_indexes_for_status publication_status
      files = find_all_by_name_and_publication_status(nil, publication_status, :conditions => 'debate_date > "2008-12-01"')

      unless files.empty?
        puts "setting indexes for publication status #{publication_status}"
        files.collect(&:debate_date).uniq.sort.each do |date|
          puts "setting indexes for: #{date}; publication status #{publication_status}"
          set_indexes_on_date date, publication_status
        end
      end
    end

    def set_yaml_index files
      path = File.dirname(files.first.name)
      File.open(storage_path+path+'/index.yaml','w') do |index|
        yaml = files.collect(&:attributes).collect{|h| h.delete('id'); h}.to_yaml
        index.write(yaml)
      end
    end

    def check_final_vs_advanced_count(final_count, date)
      advance_count = find_all_by_debate_date_and_publication_status(date, 'A').size
      if advance_count > 0
        if advance_count != final_count
          raise "expected #{advance_count} files for #{date}, but got #{final_count} final files, manual fix required."
        else
          puts "count of final and advance files matches #{final_count} for #{date}."
        end
      end
    end

    def set_indexes_on_date date, publication_status
      files = find_all_by_debate_date_and_publication_status date, publication_status
      check_final_vs_advanced_count(files.size, date) if publication_status == 'F'

      unless files.empty?
        files = files.sort_by(&:id)
        files.each_with_index do |file, index|
          file.index_on_date = (index + 1)
          file.populate_name
          download_file = data_path + file.file_name
          storage_file = storage_path + file.name
          if File.size? download_file
            FileUtils.mkdir_p File.dirname(storage_file)
            FileUtils.cp download_file, storage_file
            strip_empty_lines file
            FileUtils.rm download_file
            FileUtils.touch download_file
          end
          file.save!
        end

        set_yaml_index files
      end
    end

    def strip_empty_lines file
      lines = IO.readlines(file.storage_name)
      lines.delete_if{|line| line.strip.empty?}
      content = lines.join("\n").gsub("\r\n",'').gsub("\n\n","\n")
      File.open(file.storage_name, 'w') {|f| f.write content}
    end

    def unpersisted_dates publication_status
      files = find_all_by_publication_status_and_persisted(publication_status, false)
      dates = files.collect(&:debate_date).uniq.sort

      if publication_status == 'A'
        finals = find_all_by_publication_status_and_persisted('F', true).collect(&:debate_date).uniq.sort
        dates.delete_if {|d| finals.include? d }
      end
      dates
    end

    def unpersisted_files date, publication_status
      find_all_by_debate_date_and_publication_status_and_persisted(date, publication_status, false)
    end
  end

  def storage_name
    PersistedFile.storage_path + name
  end

  def make_file_path
    PersistedFile.file_path(debate_date, publication_status_name, parliament_file_name)
  end

  def make_file_name
    PersistedFile.file_name(debate_date, publication_status_name, parliament_file_name)
  end

  def exists?
    PersistedFile.exists?(debate_date, publication_status_name, parliament_file_name)
  end

  def publication_status_name
    PersistedFile.publication_status_name self.publication_status
  end

  def parliament_file_name
    parliament_url.split('/').last
  end

  def do_persist!
    existing = PersistedFile.find_by_parliament_url_and_publication_status(self.parliament_url, self.publication_status)
    existing = existing ? existing : self
    existing.persisted = true
    existing.persisted_date = Date.today
    existing.save!
  end

  def populate_name
    if index_on_date
      begin
        date = file_name[/\d\d\d\d\/\d\d\/\d\d/]
        type = file_name[/Hans(.)/, 1]
        name = file_name[/\d+-([\D].+.htm)$/, 1]

        index = index_on_date < 10 ? "00#{index_on_date}" : (index_on_date < 100 ? "0#{index_on_date}" : index_on_date.to_s)
        self.name = "#{date}/#{type}/#{index}_#{name}"
      rescue Exception => e
        puts "unexpected file_name syntax: #{file_name}"
        raise e
      end
    else
      raise 'need to set index_on_date before calling normalized_name ' + self.inspect
    end
  end

  def set_publication_status status_name
    self.publication_status = PersistedFile.publication_status_code(status_name)
  end

  private

    def default_persisted
      self.persisted = 0 unless self.persisted
    end
end
