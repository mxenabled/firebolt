module Firebolt
  class FileWarmer

    attr_reader :warmed_file

    def initialize
      @warmed_file = ::File.join(::Firebolt.config.file_warmer_path, 'firebolt.cache.json')
    end

    def call
      if ::File.exists?(warmed_file)
        parsed_contents
      else
        ::Firebolt::Warmer.new.call
      end
    end

  private

    def file_contents
      ::File.open(warmed_file) do |file|
        file.read
      end
    end

    def parsed_contents
      ::JSON.parse(file_contents)
    rescue => e
      warn "Could not parse #{warmed_file}, falling back to default warmer."
      return nil
    end

  end
end
