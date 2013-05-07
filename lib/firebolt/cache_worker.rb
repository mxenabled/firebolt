module Firebolt
  class CacheWorker
    include ::SuckerPunch::Worker

    def perform
      current_salt = ::Firebolt::Cache.salt
      new_salt = ::Firebolt::Cache.generate_salt

      cache_warmer = ::Firebolt::Cache::Warmer.new(new_salt)
      cache_warmer.warm

      ::Firebolt::Cache.reset_salt!(new_salt)

      cache_sweeper = ::Firebolt::Cache::Sweeper.new(current_salt)
      cache_sweeper.sweep!
    end
  end
end
