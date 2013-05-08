module Firebolt
  module Cache
    include ::Firebolt::Keys

    def fetch(suffix, options = nil, &block)
      salted_key = self.cache_key_with_salt(key_suffix, salt)
      return nil if salted_key.nil?

      ::Firebolt.config.cache.fetch(salted_key, options, &block)
    end

    def read(key_suffix, options = nil)
      salted_key = self.cache_key_with_salt(key_suffix, salt)
      return nil if salted_key.nil?

      ::Firebolt.config.cache.read(salted_key, options)
    end

    def reset_salt!(new_salt)
      ::Firebolt.config.cache.write(self.salt_key, new_salt)
    end

    def salt
      ::Firebolt.config.cache.read(self.salt_key)
    end
  end
end
