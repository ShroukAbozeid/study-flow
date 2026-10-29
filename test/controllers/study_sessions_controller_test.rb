require "test_helper"

class StudySessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as
  end

  test "renders the new study session form" do
    get new_study_session_path, params: { topic_id: topics(:two).id }

    assert_response :success
  end

  test "creates a study session" do
    assert_difference("StudySession.count", 1) do
      post study_sessions_path,
           params: { study_session: { title: "New session", topic_id: topics(:two).id } }
    end

    assert_redirected_to edit_study_plan_path(study_plans(:two))
    assert_equal "New session", StudySession.order(:id).last.title
  end

  test "renders the form when an active session already exists for the topic" do
    assert_no_difference("StudySession.count") do
      post study_sessions_path,
           params: { study_session: { title: "Duplicate active session", topic_id: topics(:one).id } }
    end

    assert_response :unprocessable_entity
  end

  test "shows a study session" do
    get study_session_path(study_sessions(:active))

    assert_response :success
    assert_includes response.body, study_sessions(:active).title
  end

  test "renders the edit study session form" do
    get edit_study_session_path(study_sessions(:active))

    assert_response :success
  end

  test "updates a study session" do
    patch study_session_path(study_sessions(:active)),
          params: { study_session: { title: "Updated session" } }

    assert_redirected_to edit_study_plan_path(study_plans(:one))
    assert_equal "Updated session", study_sessions(:active).reload.title
  end

  test "completes a study session" do
    patch complete_study_session_path(study_sessions(:active))

    assert_redirected_to edit_study_plan_path(study_plans(:one))
    assert_predicate study_sessions(:active).reload.finished_at, :present?
  end

  test "deletes a study session" do
    assert_difference("StudySession.count", -1) do
      delete study_session_path(study_sessions(:active))
    end

    assert_redirected_to edit_study_plan_path(study_plans(:one))
  end
end
