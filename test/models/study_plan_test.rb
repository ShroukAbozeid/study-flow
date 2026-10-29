require "test_helper"

class StudyPlanTest < ActiveSupport::TestCase
  test "belongs to a user and has many topics" do
    study_plan = study_plans(:one)

    assert_equal users(:one), study_plan.user
    assert_equal [ topics(:one) ], study_plan.topics.to_a
  end

  test "requires a name" do
    study_plan = StudyPlan.new(user: users(:one), name: "")

    assert_not study_plan.valid?
    assert_includes study_plan.errors.attribute_names, :name
  end
end
