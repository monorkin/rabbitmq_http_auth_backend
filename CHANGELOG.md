# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2019-05-03
### Added
- BasicResolver class, a utility class for building custom resolvers. It
  provides most functionality and nice to have method people would create in
  their own projects.
### Changed
- Resolver Runtimes now inherit from BasicResolver, meaning they have an
  expanded set of utility methods available within them.

## [1.0.0] - 2019-04-29
### Added
- Ability to configure multiple versions
- Ability to generate a mountable Rack application
- Documentation
- This changelog
