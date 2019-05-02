RSpec.describe RabbitMQHttpAuthBackend::Config do
  before do
    described_class.reset!
  end

  describe '#user_path' do
    it 'combines the default with the set values' do
      allow_resolver = proc { allow! }
      RabbitMQHttpAuthBackend.configure! do
        user do
          path '/baz/cux'
          resolver allow_resolver
        end
      end

      RabbitMQHttpAuthBackend.configure!(:v5) do
        user do
          path '/foo/bar'
        end
      end

      config = RabbitMQHttpAuthBackend::Config.new(:v5)

      expect(config.user_path).to eq('foo/bar')
      expect(config.user_resolver).to eq(allow_resolver)
    end
  end
end
