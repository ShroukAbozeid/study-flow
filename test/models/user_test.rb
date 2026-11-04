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
    user.study_preferences = {
      "week_start_day" => "Wednesday",
      "daily_reminder_notification" => { "enabled" => true }
    }

    assert_equal "Wednesday", user.preference(:study_preferences, :week_start_day)
    assert_equal "Wednesday", user.preference(:study_preferences, "week_start_day")
    assert_equal true, user.preference(:daily_reminder_notification, :enabled)
  end

  test "counts distinct active days in the current streak" do
    travel_to Time.utc(2026, 11, 4, 12) do
      study_sessions(:active).update!(started_at: Time.utc(2026, 11, 3, 10))
      study_sessions(:completed).update!(
        started_at: Time.utc(2026, 11, 2, 10),
        finished_at: Time.utc(2026, 11, 4, 11)
      )

      assert_equal 3, users(:one).current_study_streak
    end
  end

  test "keeps yesterday's streak when there is no activity today" do
    travel_to Time.utc(2026, 11, 4, 12) do
      study_sessions(:active).update!(started_at: Time.utc(2026, 11, 3, 10))
      study_sessions(:completed).update!(
        started_at: Time.utc(2026, 11, 2, 10),
        finished_at: Time.utc(2026, 11, 2, 11)
      )

      assert_equal 2, users(:one).current_study_streak
    end
  end

  test "uses the user's timezone when determining activity days" do
    user = users(:one)
    user.update!(time_zone: "Tokyo")

    travel_to Time.utc(2026, 11, 4, 15) do
      study_sessions(:active).update!(started_at: Time.utc(2026, 11, 3, 14, 59))
      study_sessions(:completed).update!(
        started_at: Time.utc(2026, 11, 3, 15, 1),
        finished_at: Time.utc(2026, 11, 3, 15, 2)
      )

      assert_equal 2, user.current_study_streak
    end
  end

  test "does not count activity from another user" do
    travel_to Time.utc(2026, 11, 4, 12) do
      study_sessions(:other_user).update!(started_at: Time.utc(2026, 11, 4, 10))

      assert_equal 0, users(:one).current_study_streak
    end
  end

  test "fills omitted preference keys from defaults before saving" do
    user = users(:one)
    user.update!(study_preferences: { week_start_day: "Wednesday" })

    expected_preferences = User::DEFAULT_STUDY_PREFERENCES.deep_stringify_keys
      .merge("week_start_day" => "Wednesday")
    assert_equal expected_preferences, user.reload.study_preferences
  end

  test "rejects a non-object study preferences value" do
    user = users(:one)
    user.study_preferences = "invalid"

    assert_not user.valid?
    assert_includes user.errors[:study_preferences], "must be an object"
  end
end
