module ExpireCache

  CACHE_ROOT = RAILS_ROOT + '/../../shared/cache/views/theyworkforyou.co.nz' unless defined? CACHE_ROOT

  private
    def uncache sub_path
      if sub_path
        path = "#{ExpireCache::CACHE_ROOT}#{sub_path}"
        if File.exist?(path)
          puts 'deleting: ' + sub_path
          File.delete(path)
        end
      end
    end

    def is_file_cache?
      ActionController::Base.cache_store.is_a?(ActiveSupport::Cache::FileStore)
    end
end
