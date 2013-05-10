module Firebolt
  class Railtie < Rails::Railtie
    initializer "firebolt.rails.configuration" do |app|
      # Configure Firebolt
      ::Firebolt.configure do |config|
        app.config.firebolt.each do |config_key, config_value|
          config_setter = "#{config_key}="
          config.__send__(config_setter, config_value) if config.respond_to?(config_setter)
        end

        # Set defaults based on Rails
        config.cache ||= ::Rails.cache
        config.cache_file_path ||= ::File.join(::Rails.root, 'tmp')
      end
    end

    # Load Firebolt Rake tasks
    rake_tasks do
      # load 'firebolt/tasks/cache.rake'
      load ::File.join('firebolt', 'tasks', 'cache.rake')
    end
  end
end
