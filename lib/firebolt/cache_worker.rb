module Firebolt
  class CacheWorker
    include ::SuckerPunch::Worker

    def perform(cache_warmer = nil)
      results = ::Firebolt::CacheStore.warm(cache_warmer)
      return unless write_results_to_cache_file?

      write_results_to_cache_file(results)
    end

  private

    def cache_file
      ::Firebolt.config.cache_file
    end

    def write_results_to_cache_file(results)
      ::File.open(cache_file, 'w') do |file|
        json_results = ::JSON.dump(results)
        file.write(json_results)
      end
    end

    def write_results_to_cache_file?
      ::Firebolt.config.cache_file_enabled?
    end
  end
end
