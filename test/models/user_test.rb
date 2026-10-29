require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "rejects user without email" do
    user = User.new(password_digest: "password")
    assert_not user.valid?
  end

  test "rejects user with invalid email" do
    user = User.new(email_address: "invalid", password_digest: "password")
    assert_not user.valid?
  end

  test "rejects user without password" do
    user = User.new(email_address: "user@example.com")
    assert_not user.valid?
  end

  test "rejects user with nil timezone" do
    user = User.new(email_address: "user@example.com",
                    password_digest: "password",
                    time_zone: nil)
    assert_not user.valid?
  end

  test "rejects user with an unsupported timezone" do
    user = User.new(email_address: "user@example.com",
                    password_digest: "password",
                    time_zone: "Mars/Olympus")

    assert_not user.valid?
    assert_includes user.errors.attribute_names, :time_zone
  end

  test "normalizes email addresses" do
    user = User.new(email_address: " USER@EXAMPLE.COM ",
                    password: "password",
                    time_zone: "UTC")

    assert_equal "user@example.com", user.email_address
  end

  test "rejects duplicate email addresses" do
    user = User.new(email_address: users(:one).email_address,
                    password: "password",
                    time_zone: "UTC")

    assert_not user.valid?
    assert_includes user.errors.attribute_names, :email_address
  end

  test "reads preferences by string or symbol key" do
    user = users(:one)
    user.study_preferences = { "week_start_day" => "Wednesday" }

    assert_equal "Wednesday", user.preference(:study_preferences, :week_start_day)
    assert_equal "Wednesday", user.preference(:study_preferences, "week_start_day")
  end
end
