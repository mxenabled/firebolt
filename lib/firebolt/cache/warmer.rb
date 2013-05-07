module Firebolt
  module Cache
    class Warmer

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
      def cache
        ::Firebolt.config.cache
      end

      def warm(&warmer)
        warmer ||= default_warmer
        results = warmer.call

        raise RuntimeError, "Warmer must return an object that responds to #each_pair." unless results.respond_to?(:each_pair)

        results.each_pair do |key, value|
          cache_key = salted_cache_key(key)
          cache.write(cache_key, value, :expires_in => expires_in)
        end

        ::Firebolt::Cache.reset_salt!(salt)
      end

    private

      def default_warmer
        ::Firebolt.config.warmer
      end

      def expires_in
        @expires_in ||= ::Firebolt::Cache.expires_in
      end

      def salted_cache_key(suffix)
        ::Firebolt::Cache.cache_key_with_salt(suffix, salt)
      end
    end
  end
end
