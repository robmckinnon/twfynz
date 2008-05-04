require 'fileutils'

namespace :kiwimp do

  # desc 'ports data file patches to server if they match'
  task :port_patches do
    Dir.glob(File.dirname(__FILE__)+'/../../data/**/*.bak').sort.reverse.each do |file|
      source = file.split('data')[1].chomp('.bak')
      remote = file.sub('.bak','.rem')
      # unless File.exists?(remote)
        # `scp root@zeal.vm.bytemark.co.uk:/var/www/twfy3/data#{source} #{remote}`
      # end

      if File.exists?(remote)
        diff = `diff --ignore-all-space #{file} #{remote}`
        diff.sub!(%Q[65c65],'')
        diff.sub!(%Q[---],'')
        diff.sub!(%Q[<div class="inSitting"><a href=/en-NZ/ThisWk/Programme/>The House next sits on Tuesday, August 21</a></div>],'')
        diff.sub!(%Q[<div class="inSitting"><a href=/en-NZ/ThisWk/Programme/>The House next sits on Tuesday, September 11</a></div>],'')
        if diff.sub('>','').sub('<','').strip.squeeze(' ').size > 0
          # puts source
        else
          # puts "cp -p /var/www/twfy3/data#{source} /var/www/twfy3/data#{source}.bak"
          `scp -p #{file.chomp('.bak')} root@zeal.vm.bytemark.co.uk:/var/www/twfy3/data#{source}`
        end
      end
    end
  end
end
