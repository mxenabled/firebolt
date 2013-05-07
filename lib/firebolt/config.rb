module Firebolt
  class Config < Hash
    CACHE_FILENAME = "firebolt.cache.json".freeze

    ##
    # Constructor!
    #
    def initialize(options = {})
      merge!(options)

      self[:cache_file_path] ||= '/tmp'
      self[:namespace] ||= ::SecureRandom.hex
    end

    ##
    # Class methods
    #

    # Creates an accessor that simply sets and reads a key in the hash:
    #
    #   class Config < Hash
    #     hash_accessor :app
    #   end
    #
    #   config = Config.new
    #   config.app = Foo
    #   config[:app] #=> Foo
    #
    #   config[:app] = Bar
    #   config.app #=> Bar
    #
    def self.hash_accessor(*names) #:nodoc:
      names.each do |name|
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{name}
            self[:#{name}]
          end

          def #{name}=(value)
            self[:#{name}] = value
          end
        METHOD
      end
    end

    hash_accessor :cache, :frequency, :cache_file_enabled, :cache_file_path, :namespace, :warmer

    ##
    # Public instance methods
    #
    def cache_file
      ::File.join(self[:cache_file_path], CACHE_FILENAME)
    end

    def cache_file_enabled?
      !! ::Firebolt.config.cache_file_enabled
    end

    def namespace
      @namespace ||= "firebolt.#{self[:namespace]}"
    end

    def warmer=(value)
      raise ArgumentError, "Warmer must respond to `call`." unless value.respond_to?(:call)

      self[:warmer] = value
    end
  end
end
