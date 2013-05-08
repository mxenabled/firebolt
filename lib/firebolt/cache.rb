module Firebolt
  class Cache
    extend ::Firebolt::Keys

    def self.fetch(suffix, options = nil, &block)
      salted_key = self.cache_key_with_salt(key_suffix, salt)
      return nil if salted_key.nil?

      ::Firebolt.config.cache.fetch(salted_key, options, &block)
    end

    def self.read(key_suffix, options = nil)
      salted_key = self.cache_key_with_salt(key_suffix, salt)
      return nil if salted_key.nil?

      ::Firebolt.config.cache.read(salted_key, options)
    end

    def self.reset_salt!(new_salt)
      ::Firebolt.config.cache.write(self.salt_key, new_salt)
    end

    def self.salt
      self.read(self.salt_key)
    end
  end
end
