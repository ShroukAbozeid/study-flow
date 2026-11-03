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

  test "does not render a topic form for another user's study plan" do
    get new_topic_path, params: { study_plan_id: study_plans(:two).id }

    assert_response :not_found
  end

  test "does not create a topic under another user's study plan" do
    assert_no_difference("Topic.count") do
      post topics_path, params: {
        topic: { name: "Unauthorized topic", estimated_hours: 2, study_plan_id: study_plans(:two).id }
      }
    end

    assert_response :not_found
  end

  test "does not render another user's topic edit form" do
    get edit_topic_path(topics(:two))

    assert_response :not_found
  end

  test "does not update another user's topic" do
    patch topic_path(topics(:two)), params: { topic: { name: "Unauthorized update" } }

    assert_response :not_found
    assert_equal "Second topic", topics(:two).reload.name
  end

  test "does not delete another user's topic" do
    assert_no_difference("Topic.count") do
      delete topic_path(topics(:two))
    end

    assert_response :not_found
  end

  test "shows a resource validation error in the topic form" do
    upload = Rack::Test::UploadedFile.new(
      StringIO.new("<html></html>"),
      "text/html",
      original_filename: "resource.html"
    )

    patch topic_path(topics(:one)), params: { topic: { resources: [ upload ] } }

    assert_response :unprocessable_entity
    assert_includes response.body, "has an unsupported file type"
  end
end
