require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated visitors to sign in" do
    get root_path

    assert_redirected_to new_session_path
  end

  test "shows the signed-in user's study plans and active sessions" do
    sign_in_as

    get root_path

    assert_response :success
    assert_includes response.body, study_plans(:one).name
    assert_includes response.body, study_sessions(:active).title
    assert_not_includes response.body, study_plans(:two).name
  end
end
