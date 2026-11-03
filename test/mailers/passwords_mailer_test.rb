require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  test "reset email includes the recipient and password reset link" do
    user = users(:one)
    user.update!(password: "current-password")
    email = PasswordsMailer.reset(user)
    token = email.body.encoded.match(%r{/passwords/([^/]+)/edit})[1]

    assert_equal [ user.email_address ], email.to
    assert_equal I18n.t("mailers.passwords.reset.subject"), email.subject
    assert_equal "from@example.com", email.from.first
    assert_equal user, User.find_by_password_reset_token!(token) # rubocop:disable Rails/DynamicFindBy
  end
end
