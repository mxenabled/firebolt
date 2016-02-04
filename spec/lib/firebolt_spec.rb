require "spec_helper"

describe ::Firebolt do
  mock_firebolt_cache!

  describe ".config" do
    it "creates a config" do
      expect(described_class.config).to be_a(Firebolt::Config)
    end
  end

  describe ".configure" do
    it "can be configured via a block" do
      described_class.configure do |config|
        expect(config).to eq(described_class.config)
      end
    end
  end

  describe ".initialize_rufus_scheduler" do
    let(:scheduler) { ::Rufus::Scheduler.new }

    before { ::Firebolt.config.warming_frequency = 1000 }

    it "creates an instance of rufus scheduler" do
      # TODO: Test the config.warmer call.
      allow(::Rufus::Scheduler).to receive(:new).and_return(scheduler)
      expect(scheduler).to receive(:every).with("1000")
      described_class.initialize_rufus_scheduler
    end
  end

  describe ".initialize!" do
    let(:warmer) do
      ::Class.new do
        include ::Firebolt::Warmer

        def perform
          {}
        end
      end
    end
    let(:warmer_instance) { warmer.new }

    before do
      ::Firebolt.config.warming_frequency = 1000
      ::Firebolt.config.warmer = warmer
    end

    it "calls the warmer" do
      expect(warmer).to receive(:new).and_return(warmer_instance)
      expect(warmer_instance).to receive(:warm)
      described_class.initialize!
      sleep 0.1 # Await async future to complete
    end
  end

  describe ".skip_warming?" do
    context "when firebolt set to skip" do
      before { ENV["FIREBOLT_SKIP_WARMING"] = "true" }
      after { ENV["FIREBOLT_SKIP_WARMING"] = nil }

      it "skips the warming" do
        expect(described_class).to be_skip_warming
      end
    end

    context "when rails testing mode" do
      before { ENV["RAILS_ENV"] = "test" }
      after { ENV["RAILS_ENV"] = nil }

      it "skips the warming" do
        expect(described_class).to be_skip_warming
      end
    end

    context "when no skip flags are set" do
      before { ENV["FIREBOLT_SKIP_WARMING"] = nil }
      after { ENV["FIREBOLT_SKIP_WARMING"] = "true" }

      it "does not skip the warming" do
        expect(described_class).to_not be_skip_warming
      end
    end
  end
end
