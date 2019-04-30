# frozen_string_literal: true

module RabbitMQHttpAuthBackend
  class App
    class ResponseFormatter < RabbitMQHttpAuthBackend::Service
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def call
        action = response[0]
        tags = response[1]

        if action == :allow && tags
          "#{action} #{tags.join(' ')}"
        else
          action.to_s
        end
      end
    end
  end
end
