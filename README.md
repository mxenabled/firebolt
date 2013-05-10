# Firebolt

Firebolt is a simple cache warmer. It warms the cache using a specially defined warmer class. It also has an optional file-based warmer to make boot-time fast!

It's not quite ready for Prime Time™ and needs specs (YIKES!). Feel free add some, if you like...

## Installation

Add this line to your application's Gemfile:

    gem 'firebolt'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install firebolt

## Usage

Firebolt uses a cache warmer that you create. Valid cache warmers must:

1. Include `Firebolt::Warmer`
2. Define a `perform` method that returns a hash

Here's an example:

```Ruby
class YourAwesomeCacheWarmer
  include ::Firebolt::Warmer

  def perform
    # Returns a hash. The keys become the cache keys and the values become cache values.
  end
end
```

To use Firebolt, you first need to configure it:

```Ruby
::Firebolt.configure do |config|
  config.cache = ::Rails.cache # Or anything that adheres to Rails's cache interface
  config.cache_file_enabled = true # Automatically enabled when cache_file_path is set
  config.cache_file_path = '/path/to/your/project/tmp' # Defaults to /tmp
  config.warming_frequency = 12.hours # In seconds. Get minutes/hours/days helper w/ ActiveSupport
  config.warmer = ::YourAwesomeCacheWarmer
end
```

Then you need to initialize it:

```Ruby
# Calling initialize! sets up the queues and starts the warming cycle.
# If you want to skip this step during spec runs (or somewhere else), set FIREBOLT_SKIP_WARMING to true.
# Warming is automatically skipped during spec runs in Rails apps.
::Firebolt.initialize!

# Also takes a block so you can initialize and configure at the same time:
::Firebolt.initialize! do |config|
  config.cache = ::Rails.cache
  config.warming_frequency = 12.hours
  config.warmer = ::YourAwesomeCacheWarmer
end
```

More documentation coming soon...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
