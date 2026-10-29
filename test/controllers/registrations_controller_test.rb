require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "renders the registration form" do
    get new_registration_path

    assert_response :success
  end

  test "creates an account and signs in the new user" do
    assert_difference("User.count", 1) do
      post registration_path, params: {
        user: {
          email_address: "new-user@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    user = User.find_by!(email_address: "new-user@example.com")
    assert_redirected_to root_path
    assert_equal user, Session.find_by!(user: user).user
    get root_path
    assert_response :success
  end

  test "renders the registration form for invalid input" do
    assert_no_difference("User.count") do
      post registration_path, params: {
        user: { email_address: "not-an-email", password: "password" }
      }
    end

    assert_response :unprocessable_entity
  end
end
