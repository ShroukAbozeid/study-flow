require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "belongs to a user" do
    assert_equal users(:one), sessions(:one).user
  end

  test "is invalid without a user" do
    session = Session.new

    assert_not session.valid?
    assert_includes session.errors.attribute_names, :user
  end
end
