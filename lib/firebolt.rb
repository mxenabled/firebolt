require "firebolt/version"
require 'firebolt/config'
require 'firebolt/cache'

module Firebolt
  # Using a mutex to control access while creating a ::Firebolt::Config
  @minimus_mutex = ::Mutex.new

  def self.config
    return @config unless @config.nil?

    @minimus_mutex.synchronize do
      @config = ::Firebolt::Config.new if @config.nil?
    end

    return @config
  end

  def self.configure
    ::Thread.exclusive do
      yield(config)
    end
  end
end
