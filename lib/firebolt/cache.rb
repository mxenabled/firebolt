module Firebolt
  module Cache
    include ::Firebolt::Keys

    def delete(key_suffix, options = nil)
      salted_key = cache_key_with_salt(key_suffix, salt)
      return nil if salted_key.nil?

      ::Firebolt.config.cache.delete(salted_key, options)
    end

    def fetch(key_suffix, options = nil, &block)
      salted_key = cache_key_with_salt(key_suffix, salt)
      return nil if salted_key.nil?

      ::Firebolt.config.cache.fetch(salted_key, options, &block)
    end

    def read(key_suffix, options = nil)
      salted_key = cache_key_with_salt(key_suffix, salt)
      return nil if salted_key.nil?

      ::Firebolt.config.cache.read(salted_key, options)
    end

    def reset_salt!(new_salt)
      ::Firebolt.config.cache.write(salt_key, new_salt)
    end

    def salt
      ::Firebolt.config.cache.read(salt_key)
    end

    def write(key_suffix, value, options = {})
      salted_key = cache_key_with_salt(key_suffix, salt)
      return nil if salted_key.nil?

      options.merge!(:expires_in => ::Firebolt.config.warming_frequency + 1.hour)
      ::Firebolt.config.cache.write(salted_key, value, options)
    end
  end
end
