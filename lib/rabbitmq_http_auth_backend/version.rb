# frozen_string_literal: true

module RabbitMQHttpAuthBackend
  module Version
    MAJOR = 1
    MINOR = 2
    PATCH = 0

    FULL = [MAJOR, MINOR, PATCH].join('.').freeze

    def self.to_s
      FULL
    end
  end

  VERSION = Version.to_s
end
