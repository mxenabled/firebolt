require "spec_helper"

describe ::Firebolt::Cache do
  mock_firebolt_cache!
  subject { klass.new }
  let(:klass) { ::Class.new { include ::Firebolt::Cache } }

  let(:key_suffix) { "test" }
  let(:options) { { :some => :thing } }
  let(:salt) { "1234" }
  let(:salt_key) { "firebolt.mx.salt" }
  let(:salted_key) { "yolo" }

  before do
    ::Firebolt.config.namespace = "mx"
    ::Firebolt.config.warming_frequency = 1000
  end

  context "with a valid salt key" do
    before do
      allow(subject).to receive(:salt_key).and_return(salt_key)
      allow(subject).to receive(:salt).and_return(salt)
      allow(subject).to receive(:cache_key_with_salt).with(key_suffix, salt).and_return(salted_key)
    end

    describe "#delete" do
      it "deletes the key" do
        expect(::Firebolt.config.cache).to receive(:delete).with(salted_key, options)
        subject.delete(key_suffix, options)
      end
    end

    describe "#fetch" do
      it "fetches out the key" do
        expect(::Firebolt.config.cache).to receive(:fetch).with(salted_key, options)
        subject.fetch(key_suffix, options)
      end
    end

    describe "#read" do
      it "reads out the key" do
        expect(::Firebolt.config.cache).to receive(:read).with(salted_key, options)
        subject.read(key_suffix, options)
      end
    end

    describe "#write" do
      let(:merged_options) { options.merge(:expires_in => 4600) }
      let(:value) { "idk" }

      it "write the key" do
        expect(::Firebolt.config.cache).to receive(:write).with(salted_key, value, merged_options)
        subject.write(key_suffix, value, options)
      end
    end
  end

  describe "#reset_salt!" do
    let(:new_salt_key) { "new_salt_key" }

    it "can reset the salt key" do
      expect(::Firebolt.config.cache).to receive(:write).with(salt_key, new_salt_key)
      subject.reset_salt!(new_salt_key)
    end
  end

  describe "#salt" do
    it "can get the salt key" do
      expect(::Firebolt.config.cache).to receive(:read).with(salt_key)
      subject.salt
    end
  end
end
