module Firebolt
  module Cache
    class Sweeper
      attr_reader :salt

      def initialize(salt)
        @salt = salt
      end

      def sweep!
        keys_to_sweep.each do |key|
          cache.delete(key)
        end
      end

    private

      def cache
        ::Firebolt.config.cache
      end

      def salted_key_matcher
        salted_key_prefix = ::Firebolt::Cache.cache_key(salt)
        /^#{::Regexp.escape(salted_key_prefix)}\./
      end

      def keys_to_sweep
        known_keys.grep(matcher)
      end

      def known_keys
        cache.get(::Firebolt::Cache.keys_key) || []
      end
    end
  end
end
