require "test_helper"
require "stringio"

class UserMailerTest < ActionMailer::TestCase
  test "notification email uses the notification recipient and content" do
    notification = notifications(:earlier_unread)

    email = UserMailer.with(notification:).notification_email

    assert_equal [ notification.user.email_address ], email.to
    assert_equal notification.title, email.subject
    assert_includes email.body.encoded, notification.title
    assert_includes email.body.encoded, notification.content
  end

  test "report email includes the report attachment" do
    user = users(:one)
    report = reports(:one)
    report.update!(name: "Weekly Progress")
    report.file.attach(io: StringIO.new("completed,started\n2,3\n"),
                       filename: "weekly_progress.csv",
                       content_type: "text/csv")

    email = UserMailer.with(user:, report:).report_email

    assert_equal [ user.email_address ], email.to
    assert_equal I18n.t("mailers.user.report_email.subject"), email.subject
    assert_includes email.body.encoded, report.name
    attachment = email.attachments["weekly_progress.csv"]
    assert_equal "text/csv", attachment.mime_type
    assert_equal "completed,started\n2,3\n", attachment.body.decoded
  end
end
