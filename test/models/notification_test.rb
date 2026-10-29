require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "belongs to a user" do
    assert_equal users(:one), notifications(:earlier_unread).user
  end

  test "requires a title and content" do
    notification = Notification.new(user: users(:one), title: "", content: "")

    assert_not notification.valid?
    assert_includes notification.errors.attribute_names, :title
    assert_includes notification.errors.attribute_names, :content
  end

  test "scopes unread notifications" do
    assert_equal [ notifications(:earlier_unread), notifications(:newest_unread) ],
                 Notification.unread.order(:created_at).to_a
  end

  test "orders notifications newest first" do
    assert_equal [ notifications(:newest_unread), notifications(:read),
                   notifications(:earlier_unread) ],
                 Notification.newest_first.to_a
  end
end
