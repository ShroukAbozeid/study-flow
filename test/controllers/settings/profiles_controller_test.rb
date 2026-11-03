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

  test "shows an avatar validation error in the profile form" do
    upload = Rack::Test::UploadedFile.new(
      StringIO.new("plain text"),
      "text/plain",
      original_filename: "avatar.txt"
    )

    patch settings_profile_path, params: { user: { avatar: upload } }

    assert_response :unprocessable_entity
    assert_includes response.body, "must be a PNG, JPEG, GIF, or WebP image"
  end
end
