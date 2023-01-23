# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rabbitmq_http_auth_backend/version'

Gem::Specification.new do |spec|
  spec.name = 'rabbitmq_http_auth_backend'
  spec.version = RabbitMQHttpAuthBackend::Version.to_s
  spec.authors = ['Stanko K.R.']
  spec.email = ['me@stanko.io']

  spec.summary = 'Mountable Rack application that implements a configurable '\
                 "API for RabbitMQ's rabbitmq-auth-backend-http"
  spec.description = spec.summary
  spec.homepage = 'https://github.com/monorkin/rabbitmq_http_auth_backend'
  spec.licenses = %w[MIT]

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host' to allow pushing to a single host or delete this
  # section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
    spec.metadata['changelog_uri'] = 'https://github.com/'\
                                     'monorkin/rabbitmq_http_auth_backend'\
                                     '/blob/master/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  IGNORED_FILES = [
    '.gitignore', '.rspec', '.travis.yml', 'Makefile', 'Rakefile',
    'CHANGELOG.md', /^bin\/.*/
  ].map { |p| Regexp.new(p) }
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end.reject { |f| IGNORED_FILES.any? { |r| r.match?(f) }  }


  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rack', '>= 1.6', '< 4.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry', '~> 0.12.2'
  spec.add_development_dependency 'rack-test', '~> 1.1.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
