module Firebolt
  class Config < Hash
    ##
    # Constructor!
    #
    def initialize(options = {})
      merge!(options)

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

    hash_accessor :cache, :namespace, :warmer, :warming_frequency

    ##
    # Public instance methods
    #

    def namespace
      @namespace ||= "firebolt.#{self[:namespace]}"
    end

    def warmer=(value)
      raise ::ArgumentError, "Warmer must include the ::Firebolt::Warmer module." unless value.ancestors.include?(::Firebolt::Warmer)
      raise ::ArgumentError, "Warmer must respond to #perform." unless value.instance_methods.include?(:perform)

      self[:warmer] = value
    end
  end
end
