require "spec_helper"

describe ::Firebolt::Keys do
  let(:klass) { ::Class.new { include ::Firebolt::Keys } }
  subject { klass.new }

  before { ::Firebolt.config.namespace = "mx" }

  describe "#cache_key" do
    it "creates a cache key via a namespace" do
      expect(subject.cache_key("yolo")).to eq("firebolt.mx.yolo")
    end
  end

  describe "#cache_key_with_salt" do
    it "creates a cache key with key suffix" do
      expect(subject.cache_key_with_salt("yolo", "test")).to eq("firebolt.mx.test.yolo")
    end
  end

  describe "#namespace" do
    it "gets the namespace from the config" do
      expect(subject.namespace).to eq("firebolt.mx")
    end
  end

  describe "#salt_key" do
    it "creates a salt key" do
      expect(subject.salt_key).to eq("firebolt.mx.salt")
    end
  end
end
