require 'secure_random'

require 'firebolt/cache/warmer'

module Firebolt
  class Cache
    def self.cache_key(suffix)
      "#{::Firebolt.config.namespace}.#{suffix}"
    end

    def self.expires_in
      ::Firebolt.config.frequency + 1.hour
    end

    def self.fetch(suffix, options = nil, &block)
      key = self.salted_cache_key(suffix)
      ::Firebolt.config.cache.fetch(key, &block)
    end

    def self.generate_salt
      ::SecureRandom.hex
    end

    def self.cache_key_with_salt(suffix, salt)
      self.cache_key("#{salt}.#{suffix}")
    end

    def self.keys_key
      cache_key(:keys)
    end

    def self.read(suffix, options = nil)
      key = self.salted_cache_key(suffix)
      return nil if key.nil?

      ::Firebolt.config.cache.read(key, options)
    end

    def self.reset_salt!(new_salt)
      ::Firebolt.config.cache.write(self.salt_key, new_salt)
    end

    def self.salt
      ::Firebolt.config.cache.read(self.salt_key)
    end

    def self.salt_key
      cache_key(:salt)
    end

    def self.salted_cache_key(suffix)
      salt_prefix = self.salt
      return nil if salt_prefix.nil?

      self.cache_key_with_salt(suffix, salt_prefix)
    end
  end
end
