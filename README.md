# RabbitMQHttpAuthBackend

Mountable Rack application that implements a configurable API for RabbitMQ's
[rabbitmq-auth-backend-http](https://github.com/rabbitmq/rabbitmq-auth-backend-http).

[![Gem Version](https://badge.fury.io/rb/rabbitmq_http_auth_backend.svg)](https://badge.fury.io/rb/rabbitmq_http_auth_backend)

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

## Index

1. [Usage](#usage)
    1. [Mounting the endpoint](#mounting-the-endpoint)
    2. [Configuration](#configuration)
    3. [Resolvers](#resolvers)
    4. [Versioning](#versioning)
    5. [Default configuration](#default-configuration)
2. [Installation](#installation)
3. [FAQ](#faq)
4. [Change log](#change-log)
5. [Development](#development)
6. [Contributing](#contributing)
7. [License](#license)

## Usage

1. [Mounting the endpoint](#mounting-the-endpoint)
2. [Configuration](#configuration)
3. [Resolvers](#resolvers)
4. [Versioning](#versioning)
5. [Default configuration](#default-configuration)

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
  mount RabbitMQHttpAuthBackend.app => '/rabbitmq/auth', as: 'rmq_auth_api'
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
        return :allow, [:admin, :moderator]
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
      return :allow
    end

    if params['permission'] == 'read' && params['name'] == 'messages'
      return :allow
    end

    :deny
  end
end
```

Most commonly used methods related to resolvers are extracted to the
`BasicResolver` class. Any class inheriting from it becomes a callable object
on the class and instance level. The user is expected to implement the `#call`
method.

The following methods are available within a class inheriting from
`BasicResolver`:

| Method        | Description                                                  |
|:--------------|:-------------------------------------------------------------|
| `username`    | Returns the user's username                                  |
| `password`    | Returns the user's password                                  |
| `name`        | Returns the name of the resource                             |
| `queue?`      | Returns true if the queried resource is a queue              |
| `exchange?`   | Returns true if the queried resource is an exchange          |
| `topic?`      | Returns true if the queried resource is a topic              |
| `resource`    | Returns the resource type (as a String, e.g. `'exchange'`)   |
| `read?`       | Returns true if the queried permission is read               |
| `write?`      | Returns true if the queried permission is write              |
| `configure?`  | Returns true if the queried permission is write              |
| `permission`  | Returns the requested permission (as a String, e.g. `'read'`)|
| `routing_key` | Returns the queried routing key                              |
| `vhost`       | Returns the queried vhost                                    |
| `ip`          | Returns the IP address of the client querying                |

The following is the same as the `TopicsResolver` from the previous example, but
rewritten using `BasicResolver`:

```ruby
class TopicsResolver < RabbitMQHttpAuthBackend::BasicResolver
  def call
    return :allow if username == 'admin'
    return :allow if name == 'messages' && read?
    :deny
  end
end

# This makes `TopicsResolver` a callable object on the class level
# > TopicsResolver.call(params)
# And it's callable on the instance level
# > TopicsResolver.new(params).call
```

A "native" configuration DSL is also provided. The DSL provides the same utility
methods as `BasicResolver` as well as `allow!`, `deny!`, `tags`, `allowed?` and
`denised?` which can be used to set the result or to query it - note that they
don't stop execution!

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
  mount RabbitMQHttpAuthBackend.app => '/rabbitmq/auth', as: 'rmq_auth_api'
end
```

You are done!

```
bash-4.4$ curl localhost:3000/rabbitmq/auth/user && echo
deny
```

## FAQ

<details>
  <summary>You use a version in your installation example. Do I have to use a version?</summary>
  <p>
    You don't have to, but I would advise you do.
    Editing the default configuration might cause you problems in the future
    when you would like to have a clean slate.
  </p>
</details>

<details>
  <summary>Why does the "native" DSL exist?</summary>
  <p>
    To provide a simple configuration language to accomplish basic tasks. I
    would advise you to use `BasicResolver` or a custom resolver callable object
    for anything other than the most basic use case e.g. check a username or IP.
  </p>
</details>

<details>
  <summary>Can my path be nested? E.g. `/foo/bar/baz/cux`?</summary>
  <p>Yes they can.</p>
</details>

<details>
  <summary>Can my path contain arguments? E.g. `/foo/:name/bar`?</summary>
  <p>At the moment, no.</p>
</details>

<details>
  <summary>Does this library handle caching for me?</summary>
  <p>
    No. This feature was removed from the original implementation of this
    library.
  </p>
  <p>
    Caching is a tricky topic. It's hard to get right. I couldn't find an
    expressive enough interface for handling cache invalidation that would
    satisfy my needs or be flexible enough to accommodate the use cases I think
    are common. Therefore I decided against implementing caching within this
    library.
  </p>
  <p>
    I recommend that you implement your custom caching and invalidation logic
    in a custom resolver.
  </p>
  <p>
    Also, use the <a href="https://github.com/rabbitmq/rabbitmq-auth-backend-cache">rabbitmq-auth-backend-cache</a> plugin.
    It provides time based client-side caching and comes standard with RabbitMQ 3.7+
  </p>
  <p>
    Here is an example of a fully configured HTTP auth backend plugin in
    conjunction with the caching plugin:
  </p>
  <pre>
    auth_backends.1 = internal
    auth_backends.2 = cache
    auth_cache.cached_backend = http
    auth_http.http_method = get
    auth_http.user_path = http://localhost:3000/rabbitmq/auth/user
    auth_http.vhost_path = http://localhost:3000/rabbitmq/auth/vhost
    auth_http.resource_path = http://localhost:3000/rabbitmq/auth/resource
    auth_http.topic_path = http://localhost:3000/rabbitmq/auth/topic
  </pre>
</details>

<details>
  <summary>How do you use Rabbit's HTTP backend?</summary>
  <p>
    Follow the installation instructions in this guide to setup your Rack
    (Rails/Roda/Sinatra/...) application as an HTTP auth backend. Then add
    the following to your `rabbitmq.conf`, located within `/etc/rabbitmq`
    (if it's not there, create it).
  </p>
  <pre>
    auth_backends.1 = internal
    auth_backends.2 = http
    auth_http.http_method = get
    auth_http.user_path = http://localhost:3000/rabbitmq/auth/user
    auth_http.vhost_path = http://localhost:3000/rabbitmq/auth/vhost
    auth_http.resource_path = http://localhost:3000/rabbitmq/auth/resource
    auth_http.topic_path = http://localhost:3000/rabbitmq/auth/topic
  </pre>
  <p>
    Assuming that your application and RabbitMQ instance are on the same
    machine, and that your application is exposed on port 3000 everything
    should just work™️.
  </p>
  <p>
    If it doesn't work try restarting RabbitMQ and your application.
  </p>
</details>

<details>
  <summary>Why does this library depend on Roda?</summary>
  <p>
    <a href="https://github.com/jeremyevans/roda">Roda</a> is, in my opinion, a lightweight framework around Rack.
    I prefer it over raw Rack - since, in my opinion, the overhead of it is
    negligible over raw Rack I use it as a more ergonomic interface to create
    Rack applications.
  </p>
</details>

## Change log

All changes between versions are logged to the change log available in the
[CHANGELOG.md file](/CHANGELOG.md).

This project follows the [semantic versioning schema](https://semver.org/).

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
[https://github.com/monorkin/rabbitmq_http_auth_backend/](https://github.com/monorkin/rabbitmq_http_auth_backend/).

## License

This software is licensed under the MIT license. A copy of the license
can be found in the [LICENSE.txt file](/LICENSE.txt) included with this
software.

**TL;DR** this software comes with absolutely no warranty of any kind.
You are free to redistribute and modify the software as long as the original
copyright notice is present in your derivative work.
