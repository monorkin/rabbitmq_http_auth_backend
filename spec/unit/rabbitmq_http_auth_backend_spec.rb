RSpec.describe RabbitMQHttpAuthBackend do
  describe '#configure!' do
    context 'given no version' do
      it 'assumes that the default version is being edited' do
        version = :default
        config_hash = {}
        config = double(:config)
        allow(config).to receive(:[]).with(version).and_return(config_hash)
        allow(RabbitMQHttpAuthBackend::Config).to(
          receive(:configuration).and_return(config)
        )

        expect(RabbitMQHttpAuthBackend::Config::Runtime).to(
          receive(:new)
          .with(config_hash)
          .and_return(double(:runtime_return, instance_eval: nil))
        )
        expect(RabbitMQHttpAuthBackend::Config).to(
          receive(:version)
          .with(version)
        )

        described_class.configure! { http_method :post }
      end
    end

    context 'given a version' do
      it 'configures the given version' do
        version = :v1
        config_hash = {}
        config = double(:config)
        allow(config).to receive(:[]).with(version).and_return(config_hash)
        allow(RabbitMQHttpAuthBackend::Config).to(
          receive(:configuration).and_return(config)
        )

        expect(RabbitMQHttpAuthBackend::Config::Runtime).to(
          receive(:new)
          .with(config_hash)
          .and_return(double(:runtime_return, instance_eval: nil))
        )
        expect(RabbitMQHttpAuthBackend::Config).to(
          receive(:version)
          .with(version)
        )

        described_class.configure!(version) { http_method :post }
      end
    end
  end

  describe '#app' do
    context 'given no version' do
      it 'uses the default configuration' do
        version = :default
        config = double(:config)
        allow(RabbitMQHttpAuthBackend::Config).to(
          receive(:new)
          .with(version)
          .and_return(config)
        )
        app = double(:app)
        allow(RabbitMQHttpAuthBackend::App).to(
          receive(:new)
          .and_return(app)
        )
        expect(RabbitMQHttpAuthBackend::App).to(
          receive(:new)
          .with(config)
        )

        described_class.app
      end
    end

    context 'given a version' do
      it "obides to the version's configuration" do
        version = :v1
        config = double(:config)
        allow(RabbitMQHttpAuthBackend::Config).to(
          receive(:new)
          .with(version)
          .and_return(config)
        )
        app = double(:app)
        allow(RabbitMQHttpAuthBackend::App).to(
          receive(:new)
          .and_return(app)
        )
        expect(RabbitMQHttpAuthBackend::App).to(
          receive(:new)
          .with(config)
        )

        described_class.app(version)
      end
    end
  end
end
