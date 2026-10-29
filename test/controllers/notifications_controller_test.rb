require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as
  end

  test "lists the signed-in user's notifications newest first" do
    get notifications_path

    assert_response :success
    assert_operator response.body.index(notifications(:newest_unread).title),
                    :<, response.body.index(notifications(:earlier_unread).title)
  end

  test "shows a notification" do
    get notification_path(notifications(:read))

    assert_response :success
  end

  test "does not show another user's notification" do
    notification = Notification.create!(user: users(:two), title: "Private", content: "Private")

    get notification_path(notification)

    assert_response :not_found
  end

  test "marks a notification as read" do
    patch mark_read_notification_path(notifications(:earlier_unread)),
          headers: { "Accept" => Mime[:turbo_stream].to_s }

    assert_response :success
    assert_predicate notifications(:earlier_unread).reload, :read?
  end

  test "marks a notification as unread" do
    patch mark_unread_notification_path(notifications(:read)),
          headers: { "Accept" => Mime[:turbo_stream].to_s }

    assert_response :success
    assert_not notifications(:read).reload.read?
  end

  test "marks all of the user's unread notifications as read" do
    other_users_notification = Notification.create!(
      user: users(:two),
      title: "Private notification",
      content: "This notification belongs to another user"
    )

    patch mark_all_read_notifications_path

    assert_redirected_to notifications_path
    assert_empty users(:one).notifications.unread
    assert_not other_users_notification.reload.read?
  end
end
