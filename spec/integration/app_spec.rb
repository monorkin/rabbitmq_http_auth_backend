require 'rack/test'

RSpec.describe RabbitMQHttpAuthBackend::App do
  include Rack::Test::Methods

  context 'given the default configuration' do
    let(:app) do
      described_class.new(
        RabbitMQHttpAuthBackend::Config.new(:default)
      ).generate
    end

    describe 'GET /user' do
      it 'responds with 200' do
        get '/user'
        expect(last_response.status).to eq(200)
      end

      it 'responds with DENY' do
        get '/user'
        expect(last_response.body).to match(/^deny$/)
      end
    end

    describe 'GET /vhost' do
      it 'responds with 200' do
        get '/vhost'
        expect(last_response.status).to eq(200)
      end

      it 'responds with DENY' do
        get '/vhost'
        expect(last_response.body).to match(/^deny$/)
      end
    end

    describe 'GET /resource' do
      it 'responds with 200' do
        get '/resource'
        expect(last_response.status).to eq(200)
      end

      it 'responds with DENY' do
        get '/resource'
        expect(last_response.body).to match(/^deny$/)
      end
    end

    describe 'GET /topic' do
      it 'responds with 200' do
        get '/topic'
        expect(last_response.status).to eq(200)
      end

      it 'responds with DENY' do
        get '/topic'
        expect(last_response.body).to match(/^deny$/)
      end
    end
  end

  context 'given a custom configuration' do
    let(:version) { :v1 }

    before do
      RabbitMQHttpAuthBackend.configure!(version) do
        http_method :post

        user do
          path '/se/anvandare'
        end

        vhost do
          path '/vhost'
        end

        resource do
          path '/se/resurs'
          resolver do
            allow!
          end
        end

        topic do
          path '/se/amne'
          resolver do
            allow! ['admin', 'manager']
          end
        end
      end
    end

    after do
      RabbitMQHttpAuthBackend::Config.reset!
    end

    let(:app) do
      described_class.new(
        RabbitMQHttpAuthBackend::Config.new(version)
      ).generate
    end

    describe 'post /se/anvandare' do
      it 'responds with 200' do
        post '/se/anvandare'
        expect(last_response.status).to eq(200)
      end

      it 'responds with DENY' do
        post '/se/anvandare'
        expect(last_response.body).to match(/^deny$/)
      end
    end

    describe 'post /vhost' do
      it 'responds with 200' do
        post '/vhost'
        expect(last_response.status).to eq(200)
      end

      it 'responds with DENY' do
        post '/vhost'
        expect(last_response.body).to match(/^deny$/)
      end
    end

    describe 'post /se/resurs' do
      it 'responds with 200' do
        post '/se/resurs'
        expect(last_response.status).to eq(200)
      end

      it 'responds with ALLOW' do
        post '/se/resurs'
        expect(last_response.body).to match(/^allow$/)
      end
    end

    describe 'post /se/amne' do
      it 'responds with 200' do
        post '/se/amne'
        expect(last_response.status).to eq(200)
      end

      it 'responds with ALLOW with tags' do
        post '/se/amne'
        expect(last_response.body).to match(/^allow admin manager$/)
      end
    end
  end
end
