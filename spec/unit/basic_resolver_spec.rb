RSpec.describe RabbitMQHttpAuthBackend::BasicResolver do
  let(:full_params) do
    {
      'username' => 'foo',
      'password' => 'bar',
      'ip' => '192.168.1.1',
      'vhost' => '/',
      'resource' => 'topic',
      'name' => 'messages',
      'permission' => 'read',
      'routing_key' => 'user.1337'
    }
  end

  let(:allow_resolver) do
    Class.new(described_class) do
      def call
        :allow
      end
    end
  end

  let(:allow_resolver_instance) do
    allow_resolver.new(full_params)
  end

  describe '.new' do
    subject { allow_resolver }

    it 'takes exactly one argument' do
      expect do
        subject.call
      end.to raise_error(ArgumentError)

      expect do
        subject.call({}, {})
      end.to raise_error(ArgumentError)

      expect(subject.call({})).to eq(:allow)
    end
  end

  describe '.call' do
    subject { allow_resolver }

    it 'instaciates the class and calls #call' do
      expect_any_instance_of(subject).to receive(:call)

      subject.call({})
    end

    it 'takes exactly one argument' do
      expect do
        subject.call
      end.to raise_error(ArgumentError)

      expect do
        subject.call({}, {})
      end.to raise_error(ArgumentError)

      expect(subject.call({})).to eq(:allow)
    end
  end

  describe '#call' do
    context 'when not overriden by the subclass' do
      it 'raises NotImplementedError' do
        klass = Class.new(described_class)
        instance = klass.new({})

        expect do
          instance.call
        end.to raise_error(NotImplementedError)
      end
    end

    context 'when overriden by the subclass' do
      it 'returns a value' do
        klass = Class.new(described_class) do
          def call
            :allow
          end
        end
        instance = klass.new({})

        expect(instance.call).to eq(:allow)
      end
    end
  end

  # It's not practice to test private methods, but this is an essential class
  # who's private interface is used to build other classes. Therefore it should
  # be tested
  describe '#params' do
    subject { allow_resolver_instance }

    it 'returns the input params' do
      expect(subject.send(:params)).to eq(full_params)
    end
  end

  describe '#username' do
    subject { allow_resolver_instance }

    it 'returns the username from the params' do
      expect(subject.send(:username)).to be_a(String)
      expect(subject.send(:username)).to eq(full_params['username'])
    end
  end

  describe '#password' do
    subject { allow_resolver_instance }

    it 'returns the password from the params' do
      expect(subject.send(:password)).to be_a(String)
      expect(subject.send(:password)).to eq(full_params['password'])
    end
  end

  describe '#vhost' do
    subject { allow_resolver_instance }

    it 'returns the vhost from the params' do
      expect(subject.send(:vhost)).to be_a(String)
      expect(subject.send(:vhost)).to eq(full_params['vhost'])
    end
  end

  describe '#ip' do
    subject { allow_resolver_instance }

    it 'returns the ip from the params' do
      expect(subject.send(:ip)).to be_a(String)
      expect(subject.send(:ip)).to eq(full_params['ip'])
    end
  end

  describe '#resource' do
    subject { allow_resolver_instance }

    it 'returns the resource from the params' do
      expect(subject.send(:resource)).to be_a(String)
      expect(subject.send(:resource)).to eq(full_params['resource'])
    end
  end

  describe '#name' do
    subject { allow_resolver_instance }

    it 'returns the name from the params' do
      expect(subject.send(:resource)).to be_a(String)
      expect(subject.send(:resource)).to eq(full_params['resource'])
    end
  end

  describe '#permission' do
    subject { allow_resolver_instance }

    it 'returns the permission from the params' do
      expect(subject.send(:permission)).to be_a(String)
      expect(subject.send(:permission)).to eq(full_params['permission'])
    end
  end

  describe '#routing_key' do
    subject { allow_resolver_instance }

    it 'returns the routing_key from the params' do
      expect(subject.send(:routing_key)).to be_a(String)
      expect(subject.send(:routing_key)).to eq(full_params['routing_key'])
    end
  end

  describe '#exchange?' do
    subject { allow_resolver_instance }

    it 'returns true if the resource is an exchange' do
      expect(subject.send(:exchange?)).to eq(false)
    end
  end

  describe '#queue?' do
    subject { allow_resolver_instance }

    it 'returns true if the resource is a queue' do
      expect(subject.send(:queue?)).to eq(false)
    end
  end

  describe '#topic?' do
    subject { allow_resolver_instance }

    it 'returns true if the resource is a topic' do
      expect(subject.send(:topic?)).to eq(true)
    end
  end

  describe '#read?' do
    subject { allow_resolver_instance }

    it 'returns true if the permission is read' do
      expect(subject.send(:read?)).to eq(true)
    end
  end

  describe '#write?' do
    subject { allow_resolver_instance }

    it 'returns true if the permission is write' do
      expect(subject.send(:write?)).to eq(false)
    end
  end

  describe '#configure?' do
    subject { allow_resolver_instance }

    it 'returns true if the permission is write' do
      expect(subject.send(:configure?)).to eq(false)
    end
  end
end
