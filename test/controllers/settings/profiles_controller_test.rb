require "test_helper"

class Settings::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as
  end

  test "renders the profile settings" do
    get settings_profile_path

    assert_response :success
  end

  test "updates profile details" do
    patch settings_profile_path, params: { user: { name: "Updated name", time_zone: "London" } }

    assert_redirected_to settings_profile_path
    assert_equal "Updated name", users(:one).reload.name
    assert_equal "London", users(:one).time_zone
  end

  test "renders the profile form when the timezone is invalid" do
    patch settings_profile_path, params: { user: { time_zone: "Mars/Olympus" } }

    assert_response :unprocessable_entity
    assert_equal "UTC", users(:one).reload.time_zone
  end
end
