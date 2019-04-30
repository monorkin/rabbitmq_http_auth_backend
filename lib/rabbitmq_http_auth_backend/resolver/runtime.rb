# frozen_string_literal: true

module RabbitMQHttpAuthBackend
  class Resolver
    class Runtime
      class Error < RabbitMQHttpAuthBackend::Error; end
      class InvalidResourceError < Error; end
      class InvalidPermissionError < Error; end

      attr_reader :params
      attr_accessor :tags
      attr_accessor :_allowed

      def initialize(params)
        @params = params
        self.tags = nil
        self._allowed = false
      end

      def allow!(tags = nil)
        self._allowed = true
        self.tags = tags
      end

      def deny!
        self._allowed = false
        self.tags = nil
      end

      def allowed?
        _allowed == true
      end

      def denied?
        !allowed?
      end

      def username
        params['username']
      end

      def password
        params['password']
      end

      def vhost
        params['vhost']
      end

      def resource
        @resource ||=
          case params['resource']
          when 'exchange' then :exchange
          when 'queue' then :queue
          when 'topic' then :topic
          else raise(InvalidResourceError)
          end
      end

      def name
        params['name']
      end

      def permission
        @permission ||=
          case params['permission']
          when 'configure' then :configure
          when 'write' then :write
          when 'read' then :read
          else raise(InvalidPermissionError)
          end
      end

      def ip
        params['ip']
      end

      def routing_key
        params['routing_key']
      end
    end
  end
end
