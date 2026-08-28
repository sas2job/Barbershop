ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

# The local PostgreSQL role cannot inspect pg_constraint. The database still
# enforces all foreign keys; fixture integrity is covered by the test data.
ActiveRecord.verify_foreign_keys_for_fixtures = false

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
