GEMSPEC='rabbitmq_http_auth_backend.gemspec'
BUILTGEM='rabbitmq_http_auth_backend.gem'

console: install
	@bundle exec ./bin/console

publish: test build
	gem push $(BUILTGEM)

build:
	gem build $(GEMSPEC) --output=$(BUILTGEM)

test: install
	@bundle exec rspec

install: Gemfile Gemfile.lock rabbitmq_http_auth_backend.gemspec
	@bundle
