require "json"
require "securerandom"
require "concurrent"
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
  FIREBOLT_MUTEX = ::Mutex.new

  def self.config
    return @config unless @config.nil?

    FIREBOLT_MUTEX.synchronize do
      @config ||= ::Firebolt::Config.new
    end

    @config
  end

  def self.configure
    FIREBOLT_MUTEX.synchronize do
      yield(config)
    end
  end

  def self.initialize_rufus_scheduler
    return if config.warming_frequency.nil?

    warming_frequency = config.warming_frequency.to_s

    scheduler = ::Rufus::Scheduler.new
    scheduler.every(warming_frequency) do
      ::Firebolt::WarmCacheJob.new.perform(config.warmer)
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
    ::Concurrent::Future.execute { ::Firebolt::WarmCacheJob.new.perform(warmer) }

    initialized!
  end

  def self.initialized!
    return @initialized unless @initialized.nil?

    FIREBOLT_MUTEX.synchronize do
      @initialized ||= true
    end

    @initialized
  end

  def self.initialized?
    !! @initialized
  end

  def self.skip_warming?
    ENV['FIREBOLT_SKIP_WARMING'] || ENV['RAILS_ENV'] == 'test'
  end
end
