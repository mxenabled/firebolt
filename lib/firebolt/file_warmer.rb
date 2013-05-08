module Firebolt
  class FileWarmer < Warmer
    def perform
      return nil unless cache_file_exists?

      return parsed_contents
    end

  private

    def cache_file
      ::Firebolt.config.cache_file
    end

    def cache_file_exists?
      ::File.exists?(cache_file)
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
