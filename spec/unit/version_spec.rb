RSpec.describe RabbitMQHttpAuthBackend::Version do
  describe '.to_s' do
    it 'returns the current version as a semver string' do
      expect(described_class.to_s).to be_a(String)
      expect(described_class.to_s).to match(/\d+\.\d+\.\d+/)
    end
  end

  describe 'VERSION' do
    it 'returns the current version as a semver string' do
      expect(RabbitMQHttpAuthBackend::VERSION).to be_a(String)
      expect(RabbitMQHttpAuthBackend::VERSION).to match(/\d+\.\d+\.\d+/)
    end
  end

  describe 'FULL' do
    it 'returns the current version as a semver string' do
      expect(RabbitMQHttpAuthBackend::Version::FULL).to be_a(String)
      expect(RabbitMQHttpAuthBackend::Version::FULL).to match(/\d+\.\d+\.\d+/)
    end
  end

  describe 'MAJOR' do
    it 'returns the major version as a number' do
      expect(RabbitMQHttpAuthBackend::Version::MAJOR).to be_a(Numeric)
      expect(RabbitMQHttpAuthBackend::Version::MAJOR.to_s).to(
        eq(described_class.to_s.split('.')[0])
      )
    end
  end

  describe 'MINOR' do
    it 'returns the minor version as a number' do
      expect(RabbitMQHttpAuthBackend::Version::MINOR).to be_a(Numeric)
      expect(RabbitMQHttpAuthBackend::Version::MINOR.to_s).to(
        eq(described_class.to_s.split('.')[1])
      )
    end
  end

  describe 'PATCH' do
    it 'returns the patch version as a number' do
      expect(RabbitMQHttpAuthBackend::Version::PATCH).to be_a(Numeric)
      expect(RabbitMQHttpAuthBackend::Version::PATCH.to_s).to(
        eq(described_class.to_s.split('.')[2])
      )
    end
  end
end
