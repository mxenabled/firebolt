require "spec_helper"

describe ::Firebolt::Warmer do
  mock_firebolt_cache!

  let(:klass) do
    ::Class.new do
      include ::Firebolt::Warmer

      def initialize(results)
        @results = results
      end

      def perform
        @results
      end
    end
  end
  subject { klass.new(results) }
  let(:results) { { "some" => "thing" } }

  before do
    ::Firebolt.config.namespace = "mx"
    ::Firebolt.config.warming_frequency = 1000
  end

  describe "#warm" do
    it "calls #perform on the warmer class" do
      expect(subject).to receive(:perform).and_return(results)
      expect(subject).to receive(:_warmer_reset_salt!)
      expect(subject).to receive(:_warmer_write_results_to_cache).with(results)
      subject.warm
    end

    it "writes the results of #perform to the cache" do
      allow(subject).to receive(:_warmer_salt).and_return("test")
      expect(subject).to receive(:_warmer_expires_in).and_return(4600)
      expect(subject).to receive(:_warmer_salted_cache_key).with("some").and_return("firebolt.mx.test.some")
      expect(::Firebolt.config.cache).to receive(:write).with("firebolt.mx.test.some", "thing", :expires_in => 4600)
      subject.warm
    end

    context "when an  result that does not respond to #each_pair is returned from #perform" do
      let(:results) { nil }

      it "raises an error" do
        expect { subject.warm }.to raise_error("Warmer must return an object that responds to #each_pair.")
      end
    end
  end
end
