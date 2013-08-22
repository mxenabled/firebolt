module Firebolt
  class WarmCacheJob
    include ::SuckerPunch::Job

    def perform(warmer_class)
      cache_warmer = warmer_class.new
      results = cache_warmer.warm
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
