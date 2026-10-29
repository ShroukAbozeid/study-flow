require "application_system_test_case"

class StudyWorkflowSystemTest < ApplicationSystemTestCase
  test "signs up and completes a study session" do
    visit new_registration_path
    fill_in "user_email_address", with: "system-user@example.com"
    fill_in "user_password", with: "system-password"
    fill_in "user_password_confirmation", with: "system-password"
    click_on "Sign up"

    assert_text "Dashboard"

    click_on "Create a Study Plan"
    fill_in "study_plan_name", with: "System test plan"
    click_on "Create Study Plan"

    plan = User.find_by!(email_address: "system-user@example.com").study_plans.find_by!(name: "System test plan")
    assert_text "System test plan"

    click_on "System test plan"
    click_on "Add a Topic"
    fill_in "topic_name", with: "System test topic"
    fill_in "topic_estimated_hours", with: "2"
    click_on "Add Topic"

    visit study_plan_path(plan)
    assert_text "System test topic"
    click_on "Start a study session"
    fill_in "Title", with: "System test session"
    click_on "Start session"

    visit study_plan_path(plan)
    assert_text "System test session"
    click_on "End this session"

    visit study_plan_path(plan)
    assert_text "System test session"
    assert_text "Completed"
  end
end
