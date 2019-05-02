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
      # NOTE: config has to be bound to the local scope as a variable to be
      # accessible from within the class that is being built
      config = self.config

      Class.new(Roda) do
        route do |r|
          RESOURCES.map do |resource|
            r.on(config.fetch(resource, :path)) do
              r.is do
                r.public_send(config.http_method) do
                  result =
                    RabbitMQHttpAuthBackend::Resolver
                    .call(r.params, config.fetch(resource, :resolver))
                  ResponseFormatter.call(result)
                end
              end
            end
          end.last
        end
      end.freeze.app
    end
  end
end

require 'rabbitmq_http_auth_backend/app/response_formatter'
