# frozen_string_literal: true

module RabbitMQHttpAuthBackend
  class Resolver
    class Runtime < BasicResolver
      attr_accessor :tags
      attr_accessor :_allowed

      def initialize(params)
        super(params)
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
    end
  end
end
