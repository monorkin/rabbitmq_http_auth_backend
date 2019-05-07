module RabbitMQHttpAuthBackend
  class App
    RESOURCES = %i[user vhost resource topic].freeze
    private_constant :RESOURCES

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def call(env)
      request = Rack::Request.new(env)

      RESOURCES.each do |resource|
        if request.path_info == "/#{config.fetch(resource, :path)}" &&
           request.request_method == config.http_method.to_s.upcase
          result =
            RabbitMQHttpAuthBackend::Resolver
            .call(request.params, config.fetch(resource, :resolver))
          response = ResponseFormatter.call(result)
          return [200, {}, [response]]
        end
      end

      [404, {}, ['']]
    end
  end
end

require 'rabbitmq_http_auth_backend/app/response_formatter'
