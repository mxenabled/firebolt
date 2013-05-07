module Firebolt
  module Cache
    class Sweeper
      attr_reader :matcher

      def initialize(matcher)
        @matcher = /^#{::Regexp.escape(matcher)}\./
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

      def keys_to_sweep
        known_keys.grep(matcher)
      end

      def known_keys
        cache.get(::Firebolt::Cache.keys_key) || []
      end
    end
  end
end
