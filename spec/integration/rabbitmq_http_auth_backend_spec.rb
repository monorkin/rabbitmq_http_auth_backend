RSpec.describe RabbitMQHttpAuthBackend do
  it 'has a version number' do
    expect(RabbitMQHttpAuthBackend::VERSION).to be_a String
    expect(RabbitMQHttpAuthBackend::VERSION).to match(/\d+\.\d+\.\d+/)
  end

  describe '#configure!' do
    before do
      RabbitMQHttpAuthBackend::Config.reset!
    end

    context 'given no version' do
      it 'assumes that the default version is being edited' do
        old_default_config = RabbitMQHttpAuthBackend::Config.new(:default)

        expect(old_default_config.http_method).to eq(:get)
        expect(old_default_config.user_path).to eq('user')

        RabbitMQHttpAuthBackend.configure! do
          http_method :post
          user do
            path '/foo/bar'
          end
        end

        new_default_config = RabbitMQHttpAuthBackend::Config.new(:default)

        expect(new_default_config.http_method).to eq(:post)
        expect(new_default_config.user_path).to eq('foo/bar')
      end
    end

    context 'given a version' do
      it 'configures the given version' do
        version = :v3
        old_config = RabbitMQHttpAuthBackend::Config.new(version)

        expect(old_config.http_method).to eq(:get)
        expect(old_config.user_path).to eq('user')

        RabbitMQHttpAuthBackend.configure!(version) do
          http_method :post
          user do
            path '/foo/bar'
          end
        end

        new_config = RabbitMQHttpAuthBackend::Config.new(version)

        expect(new_config.http_method).to eq(:post)
        expect(new_config.user_path).to eq('foo/bar')
      end
    end
  end

  describe '#app' do
    it 'builds a Roda app' do
      app = described_class.app
      expect(app.ancestors).to include(Roda)
    end
  end
end
