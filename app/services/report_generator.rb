require "csv"

class ReportGenerator
  def initialize(user:, name:)
    @user = user
    @name = name
    @class_name = "Reports::#{name.camelize}"
    @file_name = "#{class_name.constantize::FILE_NAME}_#{Time.current.strftime('%Y%m%d%H%M%S')}.csv"
  end

  def call
    csv_data = generate_csv
    Report.create(user:, name: report_class.report_name).tap do |report|
      report.file.attach(io: StringIO.new(csv_data), filename: file_name, content_type: "text/csv")
    end
  end

  private
  attr_reader :user, :class_name, :file_name, :name
  def generate_csv
    data = class_name.constantize.generate(@user)
    CSV.generate(headers: true) do |csv|
      csv << report_class.columns
      csv << data.values
    end
  end

  def report_class
    class_name.constantize
  end
end
