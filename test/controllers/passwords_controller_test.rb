require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "renders the password reset form" do
    get new_password_path

    assert_response :success
  end

  test "responds consistently when requesting a reset for an unknown email" do
    assert_no_enqueued_emails do
      post passwords_path, params: { email_address: "missing@example.com" }
    end

    assert_redirected_to new_session_path
    assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
  end

  test "queues reset instructions for a known email" do
    assert_enqueued_emails 1 do
      post passwords_path, params: { email_address: users(:one).email_address }
    end

    assert_redirected_to new_session_path
  end
end
