RSpec.describe RabbitMQHttpAuthBackend::Config do
  before do
    described_class.reset!
  end

  describe '.configuration' do
    it 'returns the full configuration for all versions as a Hash' do
      RabbitMQHttpAuthBackend.configure!(:v1) do
        http_method :post
      end

      expect(described_class.configuration).to be_a(Hash)
      expect(described_class.configuration.keys).to match_array(%i[default v1])
    end
  end

  describe '.versions' do
    it 'returns all versions' do
      RabbitMQHttpAuthBackend.configure!(:v2) do
        http_method :post
      end

      RabbitMQHttpAuthBackend.configure!(:v3) do
        http_method :post
      end

      expect(described_class.versions).to be_an(Array)
      expect(described_class.versions).to match_array(%i[default v2 v3])
    end
  end

  describe '.default_configuration_key' do
    it 'returns the default key' do
      expect(described_class.default_configuration_key).to eq(:default)
    end
  end

  describe '.default_configuration' do
    it 'returns a Hash of default values' do
      expect(described_class.default_configuration).to be_a(Hash)
    end
  end

  describe '.version' do
    context 'given an existing version' do
      it 'returns the Config object for that version' do
        version = :default
        result = described_class.version(version)
        expect(result).to be_a(described_class)
        expect(result.version).to eq(version)
      end
    end

    context 'given a non-existing version' do
      it 'returns nil' do
        expect(described_class.version(:v1337)).to eq(nil)
      end
    end
  end

  subject do
    described_class.new(:default)
  end

  describe '#http_method' do
    it 'returns the http_method' do
      method = subject.http_method
      expect(method).to be_a(Symbol)
      expect(method).to eq(:get).or eq(:post)
    end
  end

  %i[user vhost resource topic].each do |x|
    describe "##{x}_path" do
      it "returns the #{x} resource path" do
        path = subject.public_send("#{x}_path")
        expect(path).to be_a(String)
      end
    end

    describe "##{x}_resolver" do
      it "returns the #{x} resource resolver" do
        resolver = subject.public_send("#{x}_resolver")
        expect(resolver).to respond_to(:call)
        expect(resolver.arity).to eq(0).or eq(1)
      end
    end
  end

  describe '#fetch' do
    context 'given an existing resource and element' do
      it "returns it's value" do
        expect(subject.fetch(:user, :path)).to eq(subject.user_path)
      end
    end

    context 'given non-existant resource' do
      it 'returns nil' do
        expect(subject.fetch(:foo, :path)).to eq(nil)
      end
    end

    context 'given non-existant element' do
      it 'returns nil' do
        expect(subject.fetch(:user, :bar)).to eq(nil)
      end
    end

    context 'given non-existent resource and element' do
      it 'returns nil' do
        expect(subject.fetch(:foo, :bar)).to eq(nil)
      end
    end
  end
end
