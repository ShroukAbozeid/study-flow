require "test_helper"

class TopicsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as
  end

  test "renders the new topic form" do
    get new_topic_path, params: { study_plan_id: study_plans(:one).id }

    assert_response :success
  end

  test "creates a topic" do
    assert_difference("Topic.count", 1) do
      post topics_path, params: {
        topic: { name: "New topic", estimated_hours: 2, study_plan_id: study_plans(:one).id }
      }
    end

    assert_redirected_to edit_study_plan_path(study_plans(:one))
    assert_equal "New topic", Topic.order(:id).last.name
  end

  test "renders the form when topic creation is invalid" do
    assert_no_difference("Topic.count") do
      post topics_path, params: {
        topic: { name: "", estimated_hours: 0, study_plan_id: study_plans(:one).id }
      }
    end

    assert_response :unprocessable_entity
  end

  test "renders the edit topic form" do
    get edit_topic_path(topics(:one))

    assert_response :success
  end

  test "updates a topic" do
    patch topic_path(topics(:one)), params: { topic: { name: "Updated topic" } }

    assert_redirected_to edit_study_plan_path(study_plans(:one))
    assert_equal "Updated topic", topics(:one).reload.name
  end

  test "renders the edit form when topic update is invalid" do
    patch topic_path(topics(:one)), params: { topic: { name: "", estimated_hours: 0 } }

    assert_response :unprocessable_entity
    assert_equal "First topic", topics(:one).reload.name
  end

  test "deletes a topic" do
    assert_difference("Topic.count", -1) do
      delete topic_path(topics(:one))
    end

    assert_redirected_to edit_study_plan_path(study_plans(:one))
  end
end
