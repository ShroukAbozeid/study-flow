ENV["RAILS_ENV"] ||= "test"
# Consider setting MT_NO_EXPECTATIONS to not add expectations to Object.
# ENV["MT_NO_EXPECTATIONS"] = "true"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/rails"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ControllerTestHelpers
  def sign_in_as(user = users(:one))
    user.update!(password: "test-password")
    post session_path, params: { email_address: user.email_address, password: "test-password" }
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include ControllerTestHelpers
end
