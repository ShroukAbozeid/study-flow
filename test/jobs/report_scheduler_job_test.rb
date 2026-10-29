require "test_helper"

class ReportSchedulerJobTest < ActiveJob::TestCase
  test "enqueues a report when the user's configured day and time arrive" do
    travel_to Time.zone.local(2026, 11, 1, 22) do
      user = users(:one)
      user.update!(time_zone: "UTC")
      disable_weekly_reports_for(users(:two))

      assert_enqueued_with(job: WeeklyProgressReportJob, args: [ user.id ]) do
        ReportSchedulerJob.perform_now
      end
    end
  end

  test "does not enqueue reports before the configured time" do
    travel_to Time.zone.local(2026, 11, 1, 20) do
      user = users(:one)
      user.update!(time_zone: "UTC")
      disable_weekly_reports_for(users(:two))

      assert_no_enqueued_jobs(only: WeeklyProgressReportJob) do
        ReportSchedulerJob.perform_now
      end
    end
  end

  test "does not enqueue a report more than once on the same day" do
    travel_to Time.zone.local(2026, 11, 1, 22) do
      user = users(:one)
      user.update!(time_zone: "UTC")
      disable_weekly_reports_for(users(:two))
      user.reports.create!(name: "weekly_progress", created_at: Time.current)

      assert_no_enqueued_jobs(only: WeeklyProgressReportJob) do
        ReportSchedulerJob.perform_now
      end
    end
  end

  private

  def disable_weekly_reports_for(user)
    user.update!(
      study_preferences: user.study_preferences.merge(
        "weekly_progress_report" => { "enabled" => false, "day" => "Sunday", "time" => "21:00" }
      )
    )
  end
end
