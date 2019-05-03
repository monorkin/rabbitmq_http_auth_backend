# frozen_string_literal: true

module RabbitMQHttpAuthBackend
  class BasicResolver < Service
    def initialize(params)
      @params = params
    end

    protected

    attr_reader :params

    private

    def username
      params['username']
    end

    def password
      params['password']
    end

    def name
      params['name']
    end

    def queue?
      resource == 'queue'
    end

    def exchange?
      resource == 'exchange'
    end

    def topic?
      resource == 'topic'
    end

    def resource
      params['resource']
    end

    def read?
      permission == 'read'
    end

    def write?
      permission == 'write'
    end

    def configure?
      permission == 'configure'
    end

    def permission
      params['permission']
    end

    def routing_key
      params['routing_key']
    end

    def vhost
      params['vhost']
    end

    def ip
      params['ip']
    end
  end
end
