module Firebolt
  class Railtie < Rails::Railtie
    config.firebolt = ::ActiveSupport::OrderedOptions.new

    initializer "firebolt.rails.configuration" do |app|
      # Configure Firebolt
      ::Firebolt.configure do |config|
        # Set defaults based on Rails
        config.cache = ::Rails.cache

        app.config.firebolt.each do |config_key, config_value|
          config_setter = "#{config_key}="
          config.__send__(config_setter, config_value) if config.respond_to?(config_setter)
        end
      end
    end

    # Load Firebolt Rake tasks
    rake_tasks do
      # load 'firebolt/tasks/cache.rake'
      load ::File.join('firebolt', 'tasks', 'cache.rake')
    end
  end
end
