module Firebolt
  module Cache
    class Sweeper

      def cache
        ::Firebolt.config.cache
      end

      def known_keys
        cache.get(::Firebolt::Cache::KEYS_KEY)
      end

      def sweep!
        known_keys.each do |key|
          cache.delete(key)
        end
      end

    end
  end
end
