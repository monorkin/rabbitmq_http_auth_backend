# frozen_string_literal: true

module RabbitMQHttpAuthBackend
  class App
    class ResponseFormatter < RabbitMQHttpAuthBackend::Service
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def call
        # NOTE: The response is of format [:allow, [:admin, :moderator]]
        #                                  ^^^^^^  ^^^^^^^^^^^^^^^^^^^^
        #                                  action  tags
        action, tags = response

        if action == :allow && tags
          "#{action} #{tags.join(' ')}"
        else
          action.to_s
        end
      end
    end
  end
end
