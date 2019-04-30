# frozen_string_literal: true

module RabbitMQHttpAuthBackend
  class Resolver
    class Error < RabbitMQHttpAuthBackend::Error; end
    class NoResolverError < Error; end
    class NonCallableResolverError < Error; end
    class InvalidResponseError < Error; end

    attr_reader :params
    attr_reader :resolver

    def initialize(params, resolver)
      @params = params
      @resolver = resolver || raise(NoResolverError)
    end

    def call
      response = generate_response!
      validate_response!(response)
      response
    end

    private

    def generate_response!
      if resolver.is_a?(Proc) && resolver.arity.zero?
        runtime = Runtime.new(params)
        runtime.instance_eval(&resolver)
        build_response(runtime)
      elsif resolver.respond_to?(:call)
        Array(resolver.call(params))
      else
        raise(NonCallableResolverError)
      end
    end

    def validate_response!(response)
      raise(InvalidResponseError) unless response.is_a?(Array)
      raise(InvalidResponseError) unless %I[allow deny].include?(response.first)

      true
    end

    def build_response(runtime)
      symbol = runtime.allowed? ? :allow : :deny
      tags = runtime.tags
      [symbol, tags].compact
    end
  end
end

require 'rabbitmq_http_auth_backend/resolver/runtime'
