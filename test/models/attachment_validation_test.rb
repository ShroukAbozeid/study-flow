require "test_helper"
require "base64"

class AttachmentValidationTest < ActiveSupport::TestCase
  test "rejects an avatar with an unsupported content type" do
    user = users(:one)
    user.avatar.attach(upload("plain text", "avatar.txt", "text/plain"))

    assert_not user.valid?
    assert_includes user.errors[:avatar], "must be a PNG, JPEG, GIF, or WebP image"
  end

  test "rejects an oversized avatar" do
    user = users(:one)
    user.avatar.attach(upload("x" * (User::MAX_AVATAR_SIZE + 1), "avatar.png", "image/png"))

    assert_not user.valid?
    assert_includes user.errors[:avatar], "must be 5 MB or smaller"
  end

  test "accepts a supported avatar" do
    user = users(:one)
    png = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=")
    user.avatar.attach(upload(png, "avatar.png", "image/png"))

    assert user.valid?, user.errors.full_messages.join(", ")
  end

  test "rejects a topic resource with an unsupported content type" do
    topic = topics(:one)
    topic.resources.attach(upload("<html></html>", "resource.html", "text/html"))

    assert_not topic.valid?
    assert topic.errors[:resources].any? { |error| error.include?("unsupported file type") }
  end

  test "rejects an oversized topic resource" do
    topic = topics(:one)
    pdf = "%PDF-1.4\n" + ("x" * (Topic::MAX_RESOURCE_SIZE + 1))
    topic.resources.attach(upload(pdf, "resource.pdf", "application/pdf"))

    assert_not topic.valid?
    assert topic.errors[:resources].any? { |error| error.include?("must be 20 MB or smaller") }
  end

  test "accepts a supported topic resource" do
    topic = topics(:one)
    topic.resources.attach(upload("study notes", "notes.txt", "text/plain"))

    assert topic.valid?, topic.errors.full_messages.join(", ")
  end

  private

  def upload(content, filename, content_type)
    { io: StringIO.new(content), filename:, content_type: }
  end
end
