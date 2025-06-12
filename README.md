# Phillip Ridlen's Website

This repository contains the source for <https://phillipridlen.com>.
It is built with [Nanoc](https://nanoc.app) and a handful of custom
helpers.

## Running Locally

1. Install Ruby 3.4 and Bundler.
2. Run `bundle install` to fetch the gems.
3. Use `bundle exec nanoc live` to start a local server or
   `bundle exec nanoc compile` to generate the static files.

## Running Tests

Tests use [Minitest](https://github.com/seattlerb/minitest). To run the test suite:

```bash
bundle install
bundle exec ruby -Itest test/test_helpers.rb
```

This command will execute the tests located under the `test/` directory.

## Content and Code

All posts, photographs, and other written content are copyright © 2008–2025
Phillip Ridlen. Please do not republish this material without permission.

The code in this repository may be reused however you like. Fork it, copy
it, or adapt it for your own projects.
