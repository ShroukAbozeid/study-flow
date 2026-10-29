require "test_helper"

class StudyWorkflowIntegrationTest < ActionDispatch::IntegrationTest
  test "user signs in, creates a plan and topic, then completes a study session" do
    user = users(:one)
    user.update!(password: "test-password")

    post session_path,
         params: { email_address: user.email_address, password: "test-password" }
    assert_redirected_to root_url

    get root_path
    assert_response :success

    post study_plans_path, params: { study_plan: { name: "Integration plan" } }
    plan = user.study_plans.find_by!(name: "Integration plan")
    assert_redirected_to dashboard_show_path

    post topics_path,
         params: { topic: { name: "Integration topic", estimated_hours: 2, study_plan_id: plan.id } }
    topic = plan.topics.find_by!(name: "Integration topic")
    assert_redirected_to edit_study_plan_path(plan)

    post study_sessions_path,
         params: { study_session: { title: "Integration session", topic_id: topic.id } }
    study_session = topic.study_sessions.find_by!(title: "Integration session")
    assert_redirected_to edit_study_plan_path(plan)

    patch complete_study_session_path(study_session)
    assert_redirected_to edit_study_plan_path(plan)
    assert_predicate study_session.reload.finished_at, :present?

    get root_path
    assert_response :success
    assert_includes response.body, "Integration plan"
    assert_includes response.body, "Integration session"
  end
end
