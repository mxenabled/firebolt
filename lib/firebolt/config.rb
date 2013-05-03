module Firebolt
  class Config < Hash



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

    hash_accessor :frequency, :file_warmer_enabled, :file_warmer_path, :cache

    def initialize(options = {})
      merge!(options)

      #self[:insert_after_middleware] ||= ::Rails::Rack::Logger
    end

  end
end
