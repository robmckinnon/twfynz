namespace :kiwimp do
  task :init do
    `git submodule init`
    `git submodule update`
  end

  task :rm_index_cache do
    cache_dir = ENV['cache_dir']
    if cache_dir
      cmd = "rm #{cache_dir}/views/theyworkforyou.co.nz/index.cache"
      system cmd
      cmd = "wget http://theyworkforyou.co.nz/ ; rm index.html"
      system cmd
    else
      puts 'USAGE: rake kiwimp:rm_index_cache cache_dir=/opt/apps/twfynz/shared/cache'
    end
  end
end
