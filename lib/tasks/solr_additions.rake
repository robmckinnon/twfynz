namespace :solr do

  desc 'switches off solr indexing'
  task :disable_save => :environment do
    # Disable solr_optimize
    module ActsAsSolr #:nodoc:
    	module InstanceMethods
    	  def blank() end
        alias_method :original_solr_save, :solr_save
        alias_method :solr_save, :blank
    	end
    end#module ActsAsSolr
  end

  desc 'switches on solr indexing (only to be used after solr:disable)'
  task :enable_save => :environment do
    # Disable solr_optimize
    module ActsAsSolr #:nodoc:
    	module InstanceMethods
        alias_method :solr_save, :original_solr_save
    	end
    end#module ActsAsSolr
  end

  desc %{Reindexes data for all acts_as_solr models. Clears index first to get rid of orphaned records and optimizes index afterwards. RAILS_ENV=your_env to set environment. ONLY=book,person,magazine to only reindex those models; EXCEPT=book,magazine to exclude those models. START_SERVER=true to solr:start before and solr:stop after. BATCH=123 to post/commit in batches of that size: default is 300. CLEAR=false to not clear the index first; OPTIMIZE=false to not optimize the index afterwards.}
  task :reindex => :environment do
    includes = env_array_to_constants('ONLY')
    if includes.empty?
      includes = Dir.glob("#{RAILS_ROOT}/app/models/*.rb").map { |path| File.basename(path, ".rb").camelize.constantize }
    end
    excludes = env_array_to_constants('EXCEPT')
    includes -= excludes

    optimize     = env_to_bool('OPTIMIZE',     true)
    offset       = ENV['OFFSET'].to_i.nonzero? || 0
    start_server = env_to_bool('START_SERVER', false)
    clear_first  = env_to_bool('CLEAR',       true)
    verbose      = env_to_bool('VERBOSE',     false)
    batch_size   = ENV['BATCH'].to_i.nonzero? || 300

    if start_server
      puts "Starting Solr server..."
      Rake::Task["solr:start"].invoke
    end

    # Disable solr_optimize
    module ActsAsSolr::CommonMethods
      def blank() end
      alias_method :deferred_solr_optimize, :solr_optimize
      alias_method :solr_optimize, :blank
    end

    models = [Contribution]

    start_time = Time.now

    models.each do |model|
      if clear_first
        puts "Clearing index for #{model}..."
        ActsAsSolr::Post.execute(Solr::Request::Delete.new(:query => "type_t:#{model}"))
      end

      debate = Debate.find(:all).first
      offset = debate.contributions.first.id

      puts "Rebuilding index for #{model}..."
      model.rebuild_solr_index_with_offset(batch_size, {:offset => offset, :verbose => true}) do |ar, options|
        if options[:offset]
          from = options[:offset]
          to = options[:limit] + options[:offset]
          results = ar.find(:all, :conditions => ["contributions.id > ? and contributions.id <= ?", from, to])
          puts "Rebuilding index from #{from} to #{to} ... matches #{results.size}"
        else
          results = ar.find(:all)
        end
        results
      end
    end

    if models.empty?
      puts "There were no models to reindex."
    elsif optimize
      puts "Optimizing..."
      models.last.deferred_solr_optimize
    end

    puts "Time taken #{Time.now - start_time}"

    if start_server
      puts "Shutting down Solr server..."
      Rake::Task["solr:stop"].invoke
    end
  end

  def env_array_to_constants(env)
    env = ENV[env] || ''
    env.split(/\s*,\s*/).map { |m| m.singularize.camelize.constantize }.uniq
  end

  def env_to_bool(env, default)
    env = ENV[env] || ''
    case env
      when /^true$/i: true
      when /^false$/i: false
      else default
    end
  end

end