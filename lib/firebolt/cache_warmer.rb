module Firebolt
  class CacheWarmer
    include ::SuckerPunch::Worker

    attr_reader :salt

    ##
    # Constructor
    #
    def initialize
      @salt = ::Firebolt::Cache.generate_salt
    end

    ##
    # Public class methods
    #
    def self.warm(&warmer)
      warmer = self.new
      warmer.warm(&warmer)
    end

    ##
    # Public instance methods
    #
    def perform(&warmer)
      results = warm(&warmer)

      if write_to_cache_file?
        ::File.open(cache_file, 'w') do |file|
          json_results = ::JSON.dump(results)
          file.write(json_results)
        end
      end

      ::Firebolt::Cache.reset_salt!(salt)
    end

    def warm(&warmer)
      results = warmer.call if block_given?
      results ||= default_warmer.call

      raise_failed_result unless results.respond_to?(:each_pair)

      results.each_pair do |key, value|
        cache_key = salted_cache_key(key)
        cache.write(cache_key, value, :expires_in => expires_in)
      end

      results
    end

  private

    def cache
      ::Firebolt.config.cache
    end

    def cache_file
      ::Firebolt.config.cache_file
    end

    def default_warmer
      ::Firebolt.config.warmer
    end

    def expires_in
      @expires_in ||= ::Firebolt::Cache.expires_in
    end

    def raise_failed_result
      raise "Warmer must return an object that responds to #each_pair."
    end

    def salted_cache_key(suffix)
      ::Firebolt::Cache.cache_key_with_salt(suffix, salt)
    end

    def write_to_cache_file?
      ::Firebolt.config.cache_file_enabled?
    end
  end
end
