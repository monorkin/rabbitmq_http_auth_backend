# frozen_string_literal: true

module RabbitMQHttpAuthBackend
  class Config
    class Runtime
      attr_reader :configuration

      def initialize(config = nil, key = nil)
        @configuration =
          config || RabbitMQHttpAuthBackend::Config.default_configuration
        @key = key
      end

      def http_method(method)
        configuration[:http_method] = method.to_s.downcase.to_sym
      end

      def user(&block)
        self.class.new(configuration, :user).instance_eval(&block)
      end

      def vhost(&block)
        self.class.new(configuration, :vhost).instance_eval(&block)
      end

      def resource(&block)
        self.class.new(configuration, :resource).instance_eval(&block)
      end

      def topic(&block)
        self.class.new(configuration, :topic).instance_eval(&block)
      end

      def path(path)
        configuration["#{key}_path".to_sym] = path
      end

      def resolver(resolver = nil, &block)
        configuration["#{key}_resolver".to_sym] = resolver || block
      end

      protected

      attr_reader :key
    end
  end
end
