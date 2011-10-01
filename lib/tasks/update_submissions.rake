require 'ostruct'
require 'open-uri'
require 'hpricot'

namespace :kiwimp do

  desc 'update bill submission periods'
  task :update_submissions => :environment do
    update
  end

  desc 'update download submitters submissions'
  task :update_submitters => :environment do
    index = ENV['index'] || 0
    SubmissionsDownloader.submission_download index
  end

  def get_submissions
    doc = Hpricot open('http://www.parliament.nz/en-NZ/PB/SC/MakeSub/Default.htm?ps=0')
    submissions = Hash.new {|h,k| h[k] = OpenStruct.new}
    (doc/"table.listing/tbody/tr").each do |row| # /
      (row/"td/h4/a").each do |t|                # /
        url = t.attributes['href']
        submission = submissions[url]
        submission.url = url.sub('/en-NZ/PB/SC/MakeSub','')
        submission.about = t.innerHTML.strip

        details_node = t.parent.next_node.next_node
        date_node = t.parent.parent.next_node.next_node

        submission.details = details_node.nil? ? 'Submissions are now being invited.' : details_node.innerHTML
        submission.date = date_node.innerHTML
      end
    end
    submissions
  end

  def update
    submissions = get_submissions
    submissions.each_value do |submission|
      if (match = /The (.*) Committee/.match submission.details)
        name = match[1]
        committee = Committee::from_name name
        if committee
          submission.committee = committee
          puts committee.committee_name
        else
          raise "can't find committee from: " + submission.details
        end
      end

      if (submission.about.sub(' (No 2)','').sub(' (No 3)','').sub(' (No 4)','').sub(' (No 5)','').ends_with? 'Bill' and not(submission.details.include? 'expired'))
        val = submission.date[0,6]+' 20'+submission.date[7,2]
        name = submission.about.squeeze(' ')
        date = Date.parse(val)
        puts name + ' ' + date.to_s
        bills = Bill.find_all_by_bill_name name
        if bills[0].current?
          submission.bill = bills[0]
        elsif bills.size > 0
          submission.bill = bills.last
        end
        puts submission.bill.bill_name

        unless submission.committee
          committee = submission.bill.referred_to_committee
          submission.committee = committee
          puts "using bill committee instead: " + committee.committee_name if committee
        end

        submission_date = SubmissionDate.find_by_parliament_url(submission.url)

        if submission_date
          if submission_date.date != date
            submission_date.date = date
            puts 'update submission_date ' + submission_date.title
            submission_date.save!
          end
        else
          submission_date = SubmissionDate.new(:parliament_url => submission.url,
              :committee_id => (submission.committee ? submission.committee.id : 0),
              :bill_id => submission.bill.id,
              :date => date,
              :title => submission.about,
              :details => submission.details)
          puts 'new submission_date ' + submission_date.title
          submission_date.save!
        end
      end
    end
  end
end
