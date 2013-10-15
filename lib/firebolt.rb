require "json"
require "securerandom"
require "sucker_punch"
require "rufus/scheduler"

require "firebolt/keys"
require "firebolt/cache"
require "firebolt/config"
require "firebolt/file_warmer"
require "firebolt/warm_cache_job"
require "firebolt/warmer"
require "firebolt/version"

require "firebolt/railtie" if defined?(::Rails::Railtie)

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

  def self.initialize_rufus_scheduler
    return if config.warming_frequency.nil?

    warming_frequency = config.warming_frequency.to_s

    scheduler = ::Rufus::Scheduler.new
    scheduler.every(warming_frequency) do
      ::Firebolt::WarmCacheJob.new.async.perform(config.warmer)
    end
  end

  def self.initialize!(&block)
    return if initialized? || skip_warming?

    configure(&block) if block_given?

    raise "Firebolt.config.cache has not been set" unless config.cache
    raise "Firebolt.config.warmer has not been set" unless config.warmer

    initialize_rufus_scheduler

    # Initial warming
    warmer = config.use_file_warmer? ? ::Firebolt::FileWarmer : config.warmer
    ::Firebolt::WarmCacheJob.new.async.perform(config.warmer)

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
