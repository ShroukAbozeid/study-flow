require "test_helper"

class TopicTest < ActiveSupport::TestCase
  test "belongs to a study plan" do
    assert_equal study_plans(:one), topics(:one).study_plan
  end

  test "requires a name and estimated hours" do
    topic = Topic.new(study_plan: study_plans(:one), name: "", estimated_hours: nil)

    assert_not topic.valid?
    assert_includes topic.errors.attribute_names, :name
    assert_includes topic.errors.attribute_names, :estimated_hours
  end

  test "requires estimated hours greater than zero" do
    topic = Topic.new(study_plan: study_plans(:one), name: "New topic", estimated_hours: 0)

    assert_not topic.valid?
    assert_includes topic.errors.attribute_names, :estimated_hours
  end

  test "assigns the next position within its study plan" do
    topic = Topic.new(study_plan: study_plans(:one), name: "Next topic", estimated_hours: 1)

    topic.valid?

    assert_equal 2, topic.position
  end
end
