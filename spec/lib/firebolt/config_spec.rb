require "spec_helper"

describe ::Firebolt::Config do
  subject { described_class.new(options) }

  let(:options) { { :namespace => "mx" } }

  describe ".hash_accessor" do
    it "creates a reader and writer" do
      described_class.hash_accessor :thing
      expect { subject.thing = :no_way }.to_not raise_error
      expect(subject.thing).to eq(:no_way)
      expect(subject[:thing]).to eq(:no_way)
    end
  end

  describe "#namespace" do
    it "can build a namespace" do
      expect(subject.namespace).to eq("firebolt.mx")
    end
  end

  describe "#warmer=" do
    context "when does not include ::Firebolt::Warmer" do
      it "raises an error" do
        expect { subject.warmer = ::String }.to raise_error(::ArgumentError, /must include the ::Firebolt::Warmer/)
      end
    end

    context "when does not have a #perform method" do
      let(:warmer) { ::Class.new { include ::Firebolt::Warmer } }

      it "raises an error" do
        expect { subject.warmer = warmer }.to raise_error(::ArgumentError, /must respond to #perform/)
      end
    end

    context "when includes ::Firebolt::Warmer and responsd to #perform" do
      let(:warmer) do
        ::Class.new do
          include ::Firebolt::Warmer

          def perform
          end
        end
      end

      it "does not raise an error" do
        expect { subject.warmer = warmer }.to_not raise_error
      end
    end
  end
end
