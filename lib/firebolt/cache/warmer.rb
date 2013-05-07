module Firebolt
  module Cache
    class Warmer

      attr_reader :salt

      ##
      # Constructor
      #
      def initialize(salt)
        @salt = salt
      end

      ##
      # Public class methods
      #
      def self.warm(salt)
        warmer = self.new(salt)
        warmer.warm
      end

      ##
      # Public instance methods
      #
      def cache
        ::Firebolt.config.cache
      end

      def warm
        new_keys = []
        results = warmer.call

        raise RuntimeError, "Warmer must return an object that responds to #each_pair." unless results.respond_to?(:each_pair)

        results.each_pair do |key, value|
          cache_key = salted_cache_key(key)
          cache.write(cache_key, value)
          new_keys << cache_key
        end

        track_keys(new_keys)
      end

      def warmer
        ::Firebolt.config.warmer
      end

    private

      def salted_cache_key(suffix)
        ::Firebolt::Cache.cache_key("#{salt}.#{suffix}")
      end

      def track_keys(new_keys)
        keys = cache.read(::Firebolt::Cache.known_keys_key) || []
        keys += new_keys

        cache.write(::Firebolt::Cache.known_keys_key, keys)
      end
    end
  end
end
