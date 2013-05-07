module Firebolt
  module Cache
    class Sweeper
      attr_reader :entry_key_prefix_to_sweep

      def initialize(entry_key_prefix_to_sweep)
        @entry_key_prefix_to_sweep = entry_key_prefix_to_sweep
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

      def key_matcher
        /^#{::Regexp.escape(entry_key_prefix_to_sweep)}\./
      end

      def keys_to_sweep
        known_keys.grep(key_matcher)
      end

      def known_keys
        cache.get(::Firebolt::Cache.keys_key) || []
      end

    end
  end
end
