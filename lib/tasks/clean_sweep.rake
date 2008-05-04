namespace :kiwimp do

  task :migrate_down do
    ENV['VERSION'] = '1'
    Rake::Task['db:migrate'].execute
  end

  task :migrate_up do
    ENV.delete('VERSION')
    Rake::Task['db:migrate'].execute
  end

  task :clone_structure do
    Rake::Task['db:test:clone_structure'].invoke
  end

  # desc 'migrates db down and up, does db:test:clone_structure'
  task :clean_sweep => [:environment, :migrate_down, :migrate_up, :clone_structure] do
  end
end
