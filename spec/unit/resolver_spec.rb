RSpec.describe RabbitMQHttpAuthBackend::Resolver do
  describe '.call' do
    context 'given a valid' do
      context 'proc with arity 0' do
        it 'executes it in a runtime' do
          runtime = double(:runtime, allowed?: true, tags: [])
          allow(RabbitMQHttpAuthBackend::Resolver::Runtime).to(
            receive(:new)
            .and_return(runtime)
          )
          expect(runtime).to(
            receive(:instance_eval)
          )

          described_class.call({}, proc {})
        end
      end

      context 'callable object' do
        it 'calls .call on the object' do
          params = {}
          object = double(:callable_object, call: [:allow])
          expect(object).to receive(:call).with(params)
          described_class.call(params, object)
        end
      end
    end

    context 'given a invalid' do
      context 'proc with arity 0' do
        it 'denies the request' do
          result = RabbitMQHttpAuthBackend::Resolver.call({}, proc {})
          expect(result).to be_an(Array)
          expect(result.first).to eq(:deny)
        end
      end

      context 'callable object' do
        it 'calls .call on the object' do
          expect do
            RabbitMQHttpAuthBackend::Resolver.call({}, proc { |_| })
          end.to(
            raise_error(RabbitMQHttpAuthBackend::Resolver::InvalidResponseError)
          )
        end
      end
    end
  end
end
