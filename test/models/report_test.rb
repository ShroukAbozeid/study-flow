require "test_helper"
require "stringio"

class ReportTest < ActiveSupport::TestCase
  test "belongs to a user" do
    assert_equal users(:one), reports(:one).user
  end

  test "supports a file attachment" do
    report = reports(:one)
    report.file.attach(io: StringIO.new("report contents"),
                       filename: "weekly-report.txt",
                       content_type: "text/plain")

    assert_predicate report.file, :attached?
    assert_equal "report contents", report.file.download
  end
end
