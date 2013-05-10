require "json"
require "securerandom"
require "sucker_punch"
require "rufus/scheduler"

require "firebolt/keys"
require "firebolt/cache"
require "firebolt/cache_worker"
require "firebolt/config"
require "firebolt/warmer"
require "firebolt/file_warmer"

require "firebolt/version"

module Firebolt
  extend ::Firebolt::Cache

  # Using a mutex to control access while creating a ::Firebolt::Config
  @firebolt_mutex = ::Mutex.new

  def self.config
    return @config unless @config.nil?

    @firebolt_mutex.synchronize do
      @config = ::Firebolt::Config.new if @config.nil?
    end

    return @config
  end

  def self.configure
    ::Thread.exclusive do
      yield(config)
    end
  end

  def self.configure_sucker_punch
    ::SuckerPunch.config do
      queue :name => :firebolt_queue, :worker => ::Firebolt::CacheWorker, :workers => 2
    end
  end

  def self.initialize_rufus_scheduler
    frequency = ::Rufus.to_time_string(config.warming_frequency)

    ::Rufus::Scheduler.start_new.every(frequency) do
      ::SuckerPunch::Queue[:firebolt_queue].async.perform(config.warmer)
    end
  end

  def self.initialize!(&block)
    return if initialized? || skip_warming?

    configure(&block) if block_given?

    raise "Firebolt.config.cache has not been set" unless config.cache
    raise "Firebolt.config.warmer has not been set" unless config.warmer
    raise "Firebolt.config.warming_frequency has not been set" unless config.warming_frequency

    configure_sucker_punch
    initialize_rufus_scheduler

    # Initial warming
    warmer = config.use_file_warmer? ? ::Firebolt::FileWarmer : config.warmer
    ::SuckerPunch::Queue[:firebolt_queue].async.perform(warmer)

    initialized!
  end

  def self.initialized!
    return @initialized unless @initialized.nil?

    @firebolt_mutex.synchronize do
      @initialized = true if @initialized.nil?
    end

    return @initialized
  end

  def self.initialized?
    !! @initialized
  end

  def self.skip_warming?
    ENV['FIREBOLT_SKIP_WARMING'] || ENV['RAILS_ENV'] == 'test'
  end
end
