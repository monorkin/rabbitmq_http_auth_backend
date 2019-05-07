# frozen_string_literal: true

module RabbitMQHttpAuthBackend
  class Error < StandardError; end

  def self.configure!(version = nil, &block)
    version ||= RabbitMQHttpAuthBackend::Config.default_configuration_key
    RabbitMQHttpAuthBackend::Config.configuration[version] ||= {}
    cfg = RabbitMQHttpAuthBackend::Config.configuration[version]
    RabbitMQHttpAuthBackend::Config::Runtime.new(cfg).instance_eval(&block)
    RabbitMQHttpAuthBackend::Config.version(version)
  end

  def self.app(version = nil)
    version ||= RabbitMQHttpAuthBackend::Config.default_configuration_key
    config = RabbitMQHttpAuthBackend::Config.new(version)
    RabbitMQHttpAuthBackend::App.new(config)
  end
end

require 'rabbitmq_http_auth_backend/version'
require 'rabbitmq_http_auth_backend/service'
require 'rabbitmq_http_auth_backend/config'
require 'rabbitmq_http_auth_backend/resolver'
require 'rabbitmq_http_auth_backend/app'
