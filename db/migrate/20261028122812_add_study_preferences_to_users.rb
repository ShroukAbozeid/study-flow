class AddStudyPreferencesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :study_preferences, :jsonb, default: {
      daily_reminder_notification: {
        enabled: true,
        time: "08:00"
      },
      weekly_progress_report: {
        enabled: true,
        day: "Sunday",
        time: "21:00"
      },
      week_start_day: "Monday"
    }, null: false
  end
end
