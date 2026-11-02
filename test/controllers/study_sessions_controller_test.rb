require "test_helper"

class StudySessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as
  end

  test "renders the new study session form" do
    get new_study_session_path, params: { topic_id: topics(:one).id }

    assert_response :success
  end

  test "creates a study session" do
    users(:one).study_sessions.active.last.update!(finished_at: Time.current)
    assert_difference("StudySession.count", 1) do
      post study_sessions_path,
           params: { study_session: { title: "New session", topic_id: topics(:one).id } }
    end

    assert_redirected_to edit_study_plan_path(study_plans(:one))
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

  test "does not render a new session form for another user's topic" do
    get new_study_session_path, params: { topic_id: topics(:two).id }

    assert_response :not_found
  end

  test "does not create a session under another user's topic" do
    assert_no_difference("StudySession.count") do
      post study_sessions_path,
           params: { study_session: { title: "Unauthorized session", topic_id: topics(:two).id } }
    end

    assert_response :not_found
  end

  test "does not show another user's study session" do
    get study_session_path(study_sessions(:other_user))

    assert_response :not_found
  end

  test "does not render another user's study session edit form" do
    get edit_study_session_path(study_sessions(:other_user))

    assert_response :not_found
  end

  test "does not update another user's study session" do
    patch study_session_path(study_sessions(:other_user)),
          params: { study_session: { title: "Unauthorized update" } }

    assert_response :not_found
    assert_equal "Other user's session", study_sessions(:other_user).reload.title
  end

  test "does not complete another user's study session" do
    patch complete_study_session_path(study_sessions(:other_user))

    assert_response :not_found
    assert_nil study_sessions(:other_user).reload.finished_at
  end

  test "does not delete another user's study session" do
    assert_no_difference("StudySession.count") do
      delete study_session_path(study_sessions(:other_user))
    end

    assert_response :not_found
  end
end
