module Firebolt
  module Warmer
    include ::Firebolt::Keys

    ##
    # Public instance methods
    #
    def warm
      results = perform

      _warmer_write_results_to_cache(results)
      _warmer_reset_salt!

      results
    end

  private

    ##
    # Private instance methods
    #
    def _warmer_expires_in
      @_warmer_expires_in ||= ::Firebolt.config.frequency + 1.hour
    end

    def _warmer_raise_failed_result
      raise "Warmer must return an object that responds to #each_pair."
    end

    def _warmer_reset_salt!
      ::Firebolt.reset_salt!(_warmer_salt)
    end

    def _warmer_salt
      @_warmer_salt ||= ::SecureRandom.hex
    end

    def _warmer_salted_cache_key(suffix)
      cache_key_with_salt(suffix, _warmer_salt)
    end

    def _warmer_write_results_to_cache(results)
      _warmer_raise_failed_result unless results.respond_to?(:each_pair)

      results.each_pair do |key, value|
        cache_key = _warmer_salted_cache_key(key)
        ::Firebolt.config.cache.write(cache_key, value, :expires_in => _warmer_expires_in)
      end
    end
  end
end
