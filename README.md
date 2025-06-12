# Phillip Ridlen Site

This repository contains the source for Phillip Ridlen's website built with [Nanoc](https://nanoc.app/).

## Running Tests

Tests use [Minitest](https://github.com/seattlerb/minitest). To run the test suite:

```bash
bundle install
bundle exec ruby -Itest test/test_helpers.rb
```

This command will execute the tests located under the `test/` directory.
