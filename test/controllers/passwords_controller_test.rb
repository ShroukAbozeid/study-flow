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

  test "resets a password with a valid token and invalidates existing sessions" do
    user = users(:one)
    sign_in_as(user)
    token = user.reload.password_reset_token

    get edit_password_path(token)
    assert_response :success

    patch password_path(token), params: {
      password: "new-password",
      password_confirmation: "new-password"
    }

    assert_redirected_to new_session_path
    assert_empty user.sessions.reload

    post session_path,
         params: { email_address: user.email_address, password: "new-password" }
    assert_redirected_to root_url
  end

  test "does not reset a password when confirmation does not match" do
    user = users(:one)
    user.update!(password: "current-password")
    token = user.password_reset_token

    patch password_path(token), params: {
      password: "new-password",
      password_confirmation: "different-password"
    }

    assert_redirected_to edit_password_path(token)
    assert User.authenticate_by(email_address: user.email_address, password: "current-password")
    assert_nil User.authenticate_by(email_address: user.email_address, password: "new-password")
  end

  test "redirects when the reset token is invalid" do
    get edit_password_path("invalid-token")

    assert_redirected_to new_password_path
  end

  test "redirects when the reset token has expired" do
    user = users(:one)
    user.update!(password: "current-password")
    token = user.password_reset_token

    travel 1.year do
      get edit_password_path(token)
    end

    assert_redirected_to new_password_path
  end

  test "invalidates a reset token after the password changes" do
    user = users(:one)
    user.update!(password: "current-password")
    token = user.password_reset_token

    user.update!(password: "new-password")

    assert_raises(ActiveSupport::MessageVerifier::InvalidSignature) do
      User.find_by_password_reset_token!(token) # rubocop:disable Rails/DynamicFindBy
    end
  end
end
