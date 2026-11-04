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

  test "shows the current study streak" do
    sign_in_as

    travel_to Time.utc(2026, 11, 4, 12) do
      study_sessions(:active).update!(started_at: Time.utc(2026, 11, 3, 10))
      study_sessions(:completed).update!(
        started_at: Time.utc(2026, 11, 2, 10),
        finished_at: Time.utc(2026, 11, 4, 11)
      )

      get root_path
    end

    assert_response :success
    assert_includes response.body, "Current study streak"
    assert_includes response.body, "3 days"
  end
end
