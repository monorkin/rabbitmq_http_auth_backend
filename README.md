# RabbitMQHttpAuthBackend

Mountable Rack application that implements a configurable API for RabbitMQ's
[rabbitmq-auth-backend-http](https://github.com/rabbitmq/rabbitmq-auth-backend-http).

## Purpose

RabbitMQ comes bundled with the [rabbitmq-auth-backend-http](https://github.com/rabbitmq/rabbitmq-auth-backend-http)
plug-in. The purpose of this plug-in is to authorize each action of an user
connected to RabbitMQ by asking a server over HTTP if the user is allowed to
do that action.

The plugin expects the server to implement four endpoints - one for
login (`/user`), one for vhost access, one for general resources (exchanges,
queues, topics) and one for topics.

Each endpoint has to respond with a custom format to either allow or deny the
action.

This library implements all of this as a mountable Rack application. Meaning,
after minimal configuration your application can implement the four required
endpoints and respond with correctly formated responses.

## Usage

1. [Mounting the endpoint]()
2. [Configuration]()
3. [Resolvers]()
4. [Versioning]()
5. [Default configuration]()

### Mounting the endpoint

To use `RabbitMQHttpAuthBackend`, you will have to mount it within your
Rack application. This will expose it's endpoints from your application,
name spaced with by any prefix of your choosing.

The following are examples for some popular Rack based frameworks. Note that
`/rabbitmq/auth` is only a prefix and can be changed to whatever you desire.

For **Rails** applications, add the following line to your `routes.rb` file:
```ruby
# /config/routes.rb
Rails.application.routes.draw do
  mount RabbitMQHttpAuthBackend.app => '/rabbitmq/auth'
end
```

For **Sinatra** applications, add the following to `config.ru`:
```ruby
# config.ru
map '/rabbitmq/auth' do
  run RabbitMQHttpAuthBackend.app
end
```

For **Hanami** applications, add the following to `config/environment.rb`:
```ruby
Hanami.configure do
  mount RabbitMQHttpAuthBackend.app, at: '/rabbitmq/auth'
end
```

For **Roda** applications, you have to call `run` from within your routing tree:
```ruby
class MyApp < Roda
  route do |r|
    r.on '/rabbitmq/auth' do
      r.run RabbitMQHttpAuthBackend.app
    end
  end
end
```

### Configuration

`RabbitMQHttpAuthBackend` can be configured to suite your needs. Both the
HTTP method as well as the names of all the endpoints are configurable in the
following manner.

```ruby
# /config/initializers/rabbitmq_http_auth_backend.rb
RabbitMQHttpAuthBackend.configure! do
  http_method :post

  user do
    path '/anvandare'
  end

  vhost do
    path '/vhost'
  end

  resource do
    path '/resurs'
  end

  topic do
    path '/amne'
  end
end
```

### Resolvers

Resolvers are used to determine whether or not a user is allowed access to a
particular resource. Resolvers are passed as part of the configuration. They
can be any callable object - any object that responds to a `call` method that
takes one argument (the params, a hash containing RabbitMQ query information).

The return value of the resolver can be either `:allow` or `:deny`. If
additional tags need to be returned alongside `:allow` return an `Array`
containing `:allow` and an `Array` of tags - e.g. `[:allow, ['admin']]`.

```ruby
# /config/initializers/rabbitmq_http_auth_backend.rb
RabbitMQHttpAuthBackend.configure! do
  http_method :post

  user do
    path '/anvandare'
    resolver(lambda do |params|
      if params['username'] == 'admin'
        return :allow
      end

      :deny
    end)
  end

  topic do
    resolver TopicsResolver
  end
end

class TopicsResolver
  def self.call(params)
    if params['username'] == 'admin'
      return :allow, ['admin', 'manager']
    end

    :deny
  end
end
```

A "native" configuration DSL is also provided. The DSL provides utility methods
such as `username`, `password`, `vhost`, `resource`, `name`, `permission`, `ip`
and `routing_key`. Any utility methods `allow!` and `deny!` can be used to set
the return value (they don't have to be the return value).
Just note that they don't stop execution!

Not all methods return usable values for all resources. Here's a list:
* user
  - `username`
  - `password`
* vhost
  - `username`
  - `vhost`
  - `ip`
* resource
  - `username`
  - `vhost`
  - `resource` (can return `:exchange`, `:queue` or `:topic`)
  - `name`
  - `permission` (can return `:configure`, `:read` or `:write`)
* topic
  - `username`
  - `vhost`
  - `resource` (can return `:topic`)
  - `name`
  - `permission` (can return `:configure`, `:read` or `:write`)
  - `routing_key` (of the published message if the permission is `:write`, else of the queue binding)

```ruby
# /config/initializers/rabbitmq_http_auth_backend.rb
RabbitMQHttpAuthBackend.configure! do
  http_method :post

  topic do
    resolver do
      if username == 'admin'
        allow! ['admin', 'manager']
      else
        deny!
      end
    end
  end
end
```

### Versioning

Everybody makes mistakes and changes their minds. Therefore this library
enables you to create multiple versions of itself and mount them.

There is little difference to the regular usage.

Mounting:
```ruby
# /config/routes.rb
Rails.application.routes.draw do
  mount RabbitMQHttpAuthBackend.app(:v1) => '/rabbitmq/auth'
  #                                ^^^^^
end
```

Configuration:
```ruby
# /config/initializers/rabbitmq_http_auth_backend.rb
RabbitMQHttpAuthBackend.configure!(:v1) do
  #                               ^^^^^
  # ...
end
```

If no version is given the `:default` or global configuration is edited.

### Default configuration

The global default configuration can be changed by altering the configuration
for the `:default` version.

Here is the full default configuration

```ruby
# /config/initializers/rabbitmq_http_auth_backend.rb
RabbitMQHttpAuthBackend.configure!(:default) do
  http_method :get

  user do
    path '/user'
    resolver do
      deny!
    end
  end

  vhost do
    path '/vhost'
    resolver do
      deny!
    end
  end

  resource do
    path '/resource'
    resolver do
      deny!
    end
  end

  topic do
    path '/topic'
    resolver do
      deny!
    end
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
# Gemfile
gem 'rabbitmq_http_auth_backend'
```

Configure the library:

```ruby
# /config/initializers/rabbitmq_http_auth_backend.rb
RabbitMQHttpAuthBackend.configure!(:v1) do
  http_method :get

  user do
    path '/user'
    resolver do
      deny!
    end
  end

  vhost do
    path '/vhost'
    resolver do
      deny!
    end
  end

  resource do
    path '/resource'
    resolver do
      deny!
    end
  end

  topic do
    path '/topic'
    resolver do
      deny!
    end
  end
end
```

Mount the application:

```ruby
# /config/routes.rb
Rails.application.routes.draw do
  mount RabbitMQHttpAuthBackend.app => '/rabbitmq/auth'
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you
to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file
to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/monorkin/rabbitmq_http_auth_backend/.

## License

This software is licensed under the MIT license.

**TL;DR** this software comes with absolutely no warranty of any kind.
You are free to redistribute and modify the software as long as the original
copyright notice is present in your derivative work.
