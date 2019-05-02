require 'roda'

module RabbitMQHttpAuthBackend
  class App
    RESOURCES = %i[user vhost resource topic].freeze
    private_constant :RESOURCES

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def generate
      Class.new(Roda).tap do |klass|
        klass.route do |r|
          RESOURCES.each do |resource|
            r.on(config.fetch(resource, :path)) do
              r.send(config.http_method) do
                result =
                  RabbitMQHttpAuthBackend::Resolver
                  .call(r.params, config.fetch(resource, :resolver))
                ResponseFormatter.call(result)
              end
            end
          end
        end
      end.freeze.app
    end
  end
end

require 'rabbitmq_http_auth_backend/app/response_formatter'
