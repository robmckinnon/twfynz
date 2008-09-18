data = File.expand_path(File.dirname(__FILE__) + '/../../data')
donation_file = "#{data}/donations_1996_to_2007.csv"

namespace :kiwimp do

  desc "Populate data for donations in DB"
  task :load_donations => :environment do
    donation_file =
    unless File.exist?(donation_file)
      $stderr.puts "Data file not found: #{donation_file}"
    else
      Donation.delete_all
      IO.foreach(donation_file) do |line|
        begin
          line.sub!('",,','","",')
          parts = line.split('","')
          party_name = parts[0].from(1)
          donor_name = parts[1]
          parts = parts[2].split('",')
          donor_address = parts[0]
          parts = parts[1].split(',')
          amount = parts[0].to_i
          year = parts[1].to_i

          unless donor_name == 'Nil' || amount == 0
            donation = Donation.new :party_name => party_name,
              :donor_name => donor_name,
              :donor_address => donor_address,
              :amount => amount,
              :year => year
            donation.save!
          end
        rescue Exception => e
          $stderr.puts line
          raise e
        end
      end
    end
  end
end
