require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  test "reset email includes the recipient and password reset link" do
    user = users(:one)
    user.stub(:password_reset_token, "reset-token") do
      user.stub(:password_reset_token_expires_in, 15.minutes) do
        email = PasswordsMailer.reset(user)

        assert_equal [ user.email_address ], email.to
        assert_equal I18n.t("mailers.passwords.reset.subject"), email.subject
        assert_equal "from@example.com", email.from.first
        assert_includes email.body.encoded, "http://example.com/passwords/reset-token/edit"
      end
    end
  end
end
