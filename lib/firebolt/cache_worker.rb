module Firebolt
  class CacheWorker
    include ::SuckerPunch::Worker

    def perform
      current_salt = ::Firebolt::Cache.salt
      new_salt = ::Firebolt::Cache.generate_salt

      ::Firebolt::Cache::Warmer.warm(new_salt)
      ::Firebolt::Cache.reset_salt!(new_salt)
      ::Firebolt::Cache::Sweeper.sweep!(current_salt)
    end
  end
end
