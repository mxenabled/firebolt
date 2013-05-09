# Firebolt

Firebolt is a simple cache warmer. It warms the cache using a specially defined warmer class. It also has an optional file-based warmer.

It's not quite ready for Prime Time™ and needs specs (YIKES!). Feel free add some, if you like...

## Installation

Add this line to your application's Gemfile:

    gem 'firebolt'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install firebolt

## Usage

To use Firebolt, you first need to configure it:

```Ruby
::Firebolt.initialize! do |firebolt_config|
  firebolt_config.cache = ::Rails.cache
  firebolt_config.frequency = 12.hours
  firebolt_config.warmer = ::YourAwesomeCacheWarmer
end
```

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

More documentation coming soon...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
