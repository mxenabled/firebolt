module Firebolt
  module Warmer
    ##
    # Public instance methods
    #
    def warm
      results = perform

      write_results_to_cache(results)
      reset_salt!

      results
    end

  private

    ##
    # Private instance methods
    #
    def expires_in
      @expires_in ||= ::Firebolt.config.frequency + 1.hour
    end

    def raise_failed_result
      raise "Warmer must return an object that responds to #each_pair."
    end

    def reset_salt!
      ::Firebolt::Cache.reset_salt!(salt)
    end

    def salt
      @salt ||= ::SecureRandom.hex
    end

    def salted_cache_key(suffix)
      ::Firebolt::Cache.cache_key_with_salt(suffix, salt)
    end

    def write_results_to_cache(results)
      raise_failed_result unless results.respond_to?(:each_pair)

      results.each_pair do |key, value|
        cache_key = salted_cache_key(key)
        ::Firebolt.config.cache.write(cache_key, value, :expires_in => expires_in)
      end
    end
  end
end
