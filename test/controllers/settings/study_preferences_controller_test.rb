require "test_helper"

class Settings::StudyPreferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as
  end

  test "renders study preference settings" do
    get settings_study_preferences_path

    assert_response :success
  end

  test "updates permitted study preferences" do
    patch settings_study_preferences_path, params: {
      user: {
        study_preferences: {
          week_start_day: "Wednesday",
          daily_reminder_notification: { time: "09:30" }
        }
      }
    }

    assert_redirected_to settings_study_preferences_path
    preferences = users(:one).reload.study_preferences
    assert_equal "Wednesday", preferences["week_start_day"]
    assert_equal "09:30", preferences.dig("daily_reminder_notification", "time")
    assert_equal true, preferences.dig("daily_reminder_notification", "enabled")
    assert_equal true, preferences.dig("weekly_progress_report", "enabled")
    assert_equal "Sunday", preferences.dig("weekly_progress_report", "day")
    assert_equal "21:00", preferences.dig("weekly_progress_report", "time")
  end

  test "rejects invalid preference times" do
    patch settings_study_preferences_path, params: {
      user: { study_preferences: { daily_reminder_notification: { time: "25:61" } } }
    }

    assert_response :unprocessable_entity
    assert_equal "08:00", users(:one).reload.study_preferences.dig("daily_reminder_notification", "time")
  end

  test "rejects unexpected preference days" do
    patch settings_study_preferences_path, params: {
      user: { study_preferences: { weekly_progress_report: { day: "Funday" } } }
    }

    assert_response :unprocessable_entity
    assert_equal "Sunday", users(:one).reload.study_preferences.dig("weekly_progress_report", "day")
  end

  test "rejects non-boolean enabled values" do
    patch settings_study_preferences_path, params: {
      user: { study_preferences: { daily_reminder_notification: { enabled: "sometimes" } } }
    }

    assert_response :unprocessable_entity
    assert_equal true, users(:one).reload.study_preferences.dig("daily_reminder_notification", "enabled")
  end

  test "normalizes submitted checkbox values to booleans" do
    patch settings_study_preferences_path, params: {
      user: { study_preferences: { daily_reminder_notification: { enabled: "0" } } }
    }

    assert_redirected_to settings_study_preferences_path
    assert_equal false, users(:one).reload.study_preferences.dig("daily_reminder_notification", "enabled")
  end
end
