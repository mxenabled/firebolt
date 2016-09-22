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

To use Firebolt, you first need to configure it.

#### Configure & Initialize!

```Ruby
::Firebolt.configure do |config|
  # Required
  config.cache = ::Rails.cache # Or anything that adheres to Rails's cache interface
  config.warming_frequency = 12.hours # In seconds. Get minutes/hours/days helper w/ ActiveSupport
  config.warmer = ::YourAwesomeCacheWarmer

  # Optional
  config.cache_file_enabled = true
  config.cache_file_path = '/path/to/your/project/tmp' # Defaults to /tmp
end
```

Then you need to initialize it:

```Ruby
# Calling initialize! starts the warming cycle.
# It's best to skip the warming cycle while running specs. Warming is
# automatically skipped while running specs in Rails apps. In other apps, set
# FIREBOLT_SKIP_WARMING to true (or 1, or 'sandwich').
::Firebolt.initialize!

# Also takes a block so you can initialize and configure at the same time:
::Firebolt.initialize! do |config|
  config.cache = ::Rails.cache
  config.warming_frequency = 12.hours
  config.warmer = ::YourAwesomeCacheWarmer
end
```

#### Reading cached data

Firebolt provides two methods for retrieving cached data: `Firebolt.read` & `Firebolt.fetch`.

`Firebolt.read` takes your cache key and return the value from the cache.

`Firebolt.fetch` does the same thing, but also takes an optional block that is called when there is a cache miss.

#### Warming the cache

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

Firebolt uses this warmer to re-warm the cache at the frequency you configure (e.g. `config.warming_frequency`). If it's set to re-warm every 12 hours, Firebolt will warm the cache every twelve hours.

Under the hood, Firebolt keeps track of the current cache set. That way, it's able to warm a new cache set and swap it with the old cache set in place, avoiding cache misses.

#### The file warmer

Firebolt is built to be fast and unobtrusive, but sometimes warming a cache can take some time. That's where the file warmer comes in. When the file warmer is enabled, after warming the cache, Firebolt will write the cached data to a file. The next time your app starts up, it will warm the cache from the file. Each subsequent warming happens with your custom warmer.

To use file warmer, simply set the `cache_file_enabled` and `cache_file_path` config options.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
