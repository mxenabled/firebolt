$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require "firebolt"

RSpec.configure do
  def mock_firebolt_cache!
    let(:_mock_firebolt_cache) { double(:write => nil, :fetch => nil, :delete => nil, :read => nil) }

    before { ::Firebolt.config.cache = _mock_firebolt_cache }
    after { ::Firebolt.config.cache = nil }
  end
end
