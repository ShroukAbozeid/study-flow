require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  setup do
    Current.reset
  end

  teardown do
    Current.reset
  end

  test "delegates the user to the current session" do
    Current.session = sessions(:one)

    assert_equal users(:one), Current.user
  end

  test "has no user when there is no current session" do
    assert_nil Current.user
  end
end
