# frozen_string_literal: true

module RabbitMQHttpAuthBackend
  class Service
    def self.call(*args)
      new(*args).call
    end

    def call
      raise(NotImplementedError)
    end
  end
end
