#

module RabbitMQHttpAuthBackend
  module Version
    MAJOR = 1
    MINOR = 0
    PATCH = 0

    FULL = [MAJOR, MINOR, PATCH].join('.').freeze

    def self.to_s
      FULL
    end
  end

  VERSION = Version
end
