module Firebolt
  module Cache
    class Worker
      include ::SuckerPunch::Worker

      def perform
        new_salt = ::Firebolt::Cache.generate_salt

        ::Firebolt::Cache::Warmer.warm(new_salt)
        ::Firebolt::Cache.reset_salt!(new_salt)
      end
    end
  end
end
