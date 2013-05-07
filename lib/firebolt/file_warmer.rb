module Firebolt
  class FileWarmer
    def call
      if ::File.exists?(cache_file)
        parsed_contents
      else
        ::Firebolt::Warmer.new.call
      end
    end

  private

    def cache_file
      ::Firebolt.config.cache_file
    end

    def file_contents
      ::File.open(cache_file) do |file|
        file.read
      end
    end

    def parsed_contents
      ::JSON.parse(file_contents)
    rescue => e
      warn "Could not parse #{cache_file}, falling back to default warmer."
      return nil
    end
  end
end
