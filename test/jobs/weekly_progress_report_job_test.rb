require "test_helper"

class WeeklyProgressReportJobTest < ActiveJob::TestCase
  test "generates and emails an attached weekly progress report" do
    user = users(:one)

    assert_difference("Report.count", 1) do
      assert_difference -> { ActionMailer::Base.deliveries.size }, 1 do
        WeeklyProgressReportJob.perform_now(user.id)
      end
    end

    report = user.reports.order(:id).last
    assert_equal "Weekly Progress", report.name
    assert_predicate report.file, :attached?

    email = ActionMailer::Base.deliveries.last
    assert_equal [ user.email_address ], email.to
    assert_equal "Your Weekly Progress Report is Ready", email.subject
    assert_equal report.file.filename.to_s, email.attachments.first.filename
    assert_includes email.attachments.first.body.decoded, "completed,started,started_and_completed_this_week"
  end
end
