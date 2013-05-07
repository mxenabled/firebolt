require "firebolt/version"
require 'firebolt/config'
require 'firebolt/cache'
require 'firebolt/cache_warmer'

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

  def self.initialize!
    # Setup Suckerpunch
    ::SuckerPunch.config do
      queue :name => :firebolt_queue, :worker => ::Firebolt::Cache::Warmer, :workers => 1
    end

    # Setup Rufus
    frequency = ::Rufus.to_time_string(::Firebolt.config.frequency)
    ::Rufus::Scheduler.start_new.every(frequency) do
      ::SuckerPunch::Queue[:firebolt_queue].async.perform
    end

    # Initial warming
    ::Firbolt::Warmer.warm
  end
end
