# frozen_string_literal: true

module RabbitMQHttpAuthBackend
  class Config
    DEFAULT_CFG_KEY = :default
    private_constant :DEFAULT_CFG_KEY

    DENY_PROC = (proc { deny! }).freeze
    private_constant :DENY_PROC

    DEFAULT_VALUES = {
      # HTTP
      http_method: :get,
      # Paths
      user_path: '/user',
      vhost_path: '/vhost',
      resource_path: '/resource',
      topic_path: '/topic',
      # Resolvers
      user_resolver: DENY_PROC,
      vhost_resolver: DENY_PROC,
      resource_resolver: DENY_PROC,
      topic_resolver: DENY_PROC
    }.freeze
    private_constant :DEFAULT_VALUES

    def self.configuration
      @configuration ||= { default_configuration_key => default_configuration }
    end

    def self.reset!
      @configuration = { default_configuration_key => default_configuration }
    end

    def self.versions
      configuration.keys
    end

    def self.default_configuration_key
      DEFAULT_CFG_KEY
    end

    def self.default_configuration
      {}.merge(DEFAULT_VALUES)
    end

    def self.version(version)
      return unless versions.include?(version)

      new(version)
    end

    attr_reader :version

    def initialize(version = DEFAULT_CFG_KEY)
      @version = version.to_sym
    end

    def http_method
      data[:http_method]
    end

    def user_path
      sanitize_path(data[:user_path])
    end

    def user_resolver
      data[:user_resolver]
    end

    def vhost_path
      sanitize_path(data[:vhost_path])
    end

    def vhost_resolver
      data[:vhost_resolver]
    end

    def resource_path
      sanitize_path(data[:resource_path])
    end

    def resource_resolver
      data[:resource_resolver]
    end

    def topic_path
      sanitize_path(data[:topic_path])
    end

    def topic_resolver
      data[:topic_resolver]
    end

    def fetch(resource, element)
      method = "#{resource}_#{element}".to_sym
      return nil unless respond_to?(method)
      public_send(method)
    end

    private

    def data
      @data ||= begin
        defaults = self.class.configuration[DEFAULT_CFG_KEY]
        cfg = self.class.configuration[version] || {}
        defaults.merge(cfg).freeze
      end
    end

    def sanitize_path(path)
      path.gsub(%r{^/}, '')
    end
  end
end

require 'rabbitmq_http_auth_backend/config/runtime'
