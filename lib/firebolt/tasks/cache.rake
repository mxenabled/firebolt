require 'rake'
require 'fileutils'

namespace :firebolt do
  namespace :cache do
    desc 'Rebuild the cache by purging and re-warming'
    task :rebuild => :environment do
      ::Rake::Task['firebolt:cache:purge'].invoke
      ::Rake::Task['firebolt:cache:warm'].invoke
      puts 'Cache rebuilt'
    end

    desc 'Purge the cache and startup file'
    task :purge => :environment do
      pattern = ::Firebolt.cache_key_with_salt('*', ::Firebolt.salt)
      puts "Purging keys matching pattern '#{pattern}'"
      ::Firebolt.config.cache.delete_matched(pattern)

      if ::Firebolt.config.cache_file_readable?
        cache_file = ::Firebolt.config.cache_file
        puts "Removing cache file at '#{cache_file}'"
        ::FileUtils.rm(cache_file)
      end
    end

    desc 'Warm the cache with a new salt'
    task :warm => :environment do
      ::Firebolt.initialize!
      warmer = ::Firebolt.config.warmer
      puts "Warming the cache with #{warmer}"
      ::Firebolt::WarmCacheJob.new.perform(warmer)
    end
  end
end
