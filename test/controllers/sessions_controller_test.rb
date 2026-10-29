require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "renders the sign-in form" do
    get new_session_path

    assert_response :success
  end

  test "signs in a user with valid credentials" do
    user = users(:one)
    user.update!(password: "correct password")

    post session_path, params: { email_address: user.email_address, password: "correct password" }

    assert_redirected_to root_url
    get root_path
    assert_response :success
  end

  test "rejects invalid credentials" do
    user = users(:one)
    user.update!(password: "correct password")

    post session_path, params: { email_address: user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_equal "Try another email address or password.", flash[:alert]
  end

  test "signs out the current session" do
    sign_in_as
    session_count = users(:one).sessions.count

    delete session_path

    assert_response :see_other
    assert_redirected_to new_session_path
    assert_equal session_count - 1, users(:one).sessions.count
  end
end
