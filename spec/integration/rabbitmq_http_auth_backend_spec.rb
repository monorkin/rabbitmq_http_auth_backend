RSpec.describe RabbitMQHttpAuthBackend do
  it 'has a version number' do
    expect(RabbitMQHttpAuthBackend::VERSION).not_to be nil
    expect(RabbitMQHttpAuthBackend::VERSION).to be_a String
  end

  describe '#configure!' do
    context 'given no version' do
      it 'assumes that the default version is being edited' do
      end
    end

    context 'given a version' do
      it 'configures the given version' do
      end

      it 'combines the default with version specific configuration' do
      end

      it 'combines version with defualt configuration so that the version config takes presedence' do
      end
    end
  end

  describe '#app' do
    context 'given no version' do
      it 'uses the default configuration' do
      end
    end

    context 'given a version' do
      it 'builds a Roda app' do
      end

      it "obides to the version's configuration" do
      end
    end
  end
end
