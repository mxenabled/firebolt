module Firebolt
  class CacheWorker
    include ::SuckerPunch::Worker

    def perform
      entry_key_prefix_to_sweep = ::Firebolt::Cache.entry_key_prefix
      new_salt = ::Firebolt::Cache.generate_salt

      cache_warmer = ::Firebolt::Cache::Warmer.new(new_salt)
      cache_warmer.warm

      ::Firebolt::Cache.reset_salt!(new_salt)

      cache_sweeper = ::Firebolt::Cache::Sweeper.new(entry_key_prefix_to_sweep)
      cache_sweeper.sweep!
    end
  end
end
