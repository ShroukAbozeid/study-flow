require "test_helper"

class StudyPlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as
  end

  test "shows a study plan" do
    get study_plan_path(study_plans(:one))

    assert_response :success
    assert_includes response.body, study_plans(:one).name
  end

  test "does not show another user's study plan" do
    get study_plan_path(study_plans(:two))

    assert_response :not_found
  end

  test "renders the new study plan form" do
    get new_study_plan_path

    assert_response :success
    assert_select "h1", "Create Study Plan"
  end

  test "creates a study plan for the signed-in user" do
    assert_difference("users(:one).study_plans.count", 1) do
      post study_plans_path, params: { study_plan: { name: "New plan" } }
    end

    assert_redirected_to dashboard_show_path
    assert_equal users(:one), StudyPlan.find_by!(name: "New plan").user
  end

  test "renders the form when study plan creation is invalid" do
    assert_no_difference("StudyPlan.count") do
      post study_plans_path, params: { study_plan: { name: "" } }
    end

    assert_response :success
  end

  test "renders the edit study plan form" do
    get edit_study_plan_path(study_plans(:one))

    assert_response :success
    assert_select "h1", "Update Study Plan:"
  end

  test "updates a study plan" do
    patch study_plan_path(study_plans(:one)),
          params: { study_plan: { name: "Updated plan" } }

    assert_redirected_to study_plan_path(study_plans(:one))
    assert_equal "Updated plan", study_plans(:one).reload.name
  end

  test "renders the edit form when study plan update is invalid" do
    patch study_plan_path(study_plans(:one)),
          params: { study_plan: { name: "" } }

    assert_response :success
    assert_equal "First study plan", study_plans(:one).reload.name
  end

  test "deletes a study plan" do
    assert_difference("StudyPlan.count", -1) do
      delete study_plan_path(study_plans(:one))
    end

    assert_redirected_to dashboard_show_path
  end
end
