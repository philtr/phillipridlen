require 'minitest/autorun'

# Use a minimal Gemfile for the test environment
ENV['BUNDLE_GEMFILE'] = File.expand_path('Gemfile', __dir__)

# Stub Bundler to avoid loading missing gems when requiring helpers
module Bundler
  def self.require(*); end
end

# Stub Nanoc helpers used in helpers.rb
module Nanoc
  module Helpers
    module LinkTo; end
    module Rendering; end
  end
end

def use_helper(*); end

require_relative '../lib/helpers'

class HelpersTest < Minitest::Test
  def setup
    @posts = [
      { date: Time.new(2021, 1, 1) },
      { date: Time.new(2020, 1, 1) },
      { date: Time.new(2022, 1, 1) }
    ]
  end

  def test_posts_sorted_by_date_descending
    sorted = posts_sorted_by_date(@posts, direction: :desc)
    dates = sorted.map { |p| p[:date] }
    assert_equal [Time.new(2022, 1, 1), Time.new(2021, 1, 1), Time.new(2020, 1, 1)], dates
  end

  def test_posts_sorted_by_date_ascending
    sorted = posts_sorted_by_date(@posts, direction: :asc)
    dates = sorted.map { |p| p[:date] }
    assert_equal [Time.new(2020, 1, 1), Time.new(2021, 1, 1), Time.new(2022, 1, 1)], dates
  end
end
