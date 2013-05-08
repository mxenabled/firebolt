module Firebolt
  module Keys
    def cache_key(key_suffix)
      "#{namespace}.#{key_suffix}"
    end

    def cache_key_with_salt(key_suffix, salt)
      "#{namespace}.#{salt}.#{key_suffix}"
    end

    def namespace
      ::Firebolt.config.namespace
    end

    def salt_key
      cache_key(:salt)
    end
  end
end
