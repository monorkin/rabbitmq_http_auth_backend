# /config/initializers/rabbitmq_http_auth_backend.rb
RabbitMQHttpAuthBackend.configure! do
  user do
    path '/foo/bar'
    resolver do
      allow! [:admin, :manager]
    end
  end

  resource do
    path '/foo/bar/resource'
    resolver ResourceResolver
  end

  topic do
    resolver do
      return allow! if path == 'patka'
      deny!
    end
  end
end

# somewhere
class ResourceResolver
  def self.call(params)
    # ...
  end
end

# /config/routes.rb
RailsApp::Application.routes.draw do
  mount RabbitMQHttpAuthBackend.app => '/rabbitmq/auth'
  # mount RabbitMQHttpAuthBackend.app, at: '/rabbitmq/auth'
  #       ^^^^^^^^      ^^^^^^^^^^^^^^^^
  #       Rack app      mount point
end

## VERSIONING

# /config/initializers/rabbitmq_http_auth_backend.rb
RabbitMQHttpAuthBackend.configure!(:v2) do
  user do
    path '/foo/bar'
    resolver do
      allow! [:admin, :manager]
    end
  end

  resource do
    path '/foo/bar/resource'
    resolver ResourceResolver
  end

  topic do
    resolver do
      return allow! if path == 'patka'
      deny!
    end
  end
end

# somewhere
class ResourceResolver
  def self.call(params)
    # ...
  end
end

# /config/routes.rb
RailsApp::Application.routes.draw do
  mount RabbitMQHttpAuthBackend.app(:v2) => '/rabbitmq/auth/v2'
  # mount RabbitMQHttpAuthBackend.app, at: '/rabbitmq/auth'
  #       ^^^^^^^^      ^^^^^^^^^^^^^^^^
  #       Rack app      mount point
end
