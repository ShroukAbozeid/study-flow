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
  end
end
