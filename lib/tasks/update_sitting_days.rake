require 'open-uri'
require 'hpricot'

namespace :kiwimp do

  desc 'update sitting days using data in database'
  task :update_sitting_days => [:environment] do
    PersistedFile.find(:all).each do |file|
      day = SittingDay.find_by_date(file.debate_date)
      day = SittingDay.new(:date=>file.debate_date) unless day

      status = file.publication_status
      day.has_oral_answers = true if status == 'U'
      day.has_advance = true      if status == 'A'
      day.has_final = true        if status == 'F'

      day.save!
    end
  end

  desc 'load sitting days from parliament site'
  task :load_sitting_days => :environment do
    doc = Hpricot open("http://www.parliament.nz/en-NZ/ThisWk/Programme/9/4/d/00CLOOCThisWkProgramme1-House-sitting-programme.htm")
    dates = (doc/'h2').collect do |m|
      (m.parent/'td strong em').collect do |d|
        Date.parse(d.innerText + ' ' + m.innerText + ' 2008').to_s
      end
    end.flatten

    dates.each do |date|
      day = SittingDay.find_by_date(date)
      day = SittingDay.new(:date => date) unless day
      day.save!
    end
  end

end
