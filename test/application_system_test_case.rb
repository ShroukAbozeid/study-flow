# require "test_helper"
require "minitest/rails/capybara"

# class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
#   driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

#   register_spec_type(self) do |desc, *addl|
#     addl.include? :system
#   end
# end

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  if ENV["CI"].present?
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
  else
    chromedriver_url = ENV["CHROMEDRIVER_URL"] || begin
      wsl_host = File.read("/etc/resolv.conf")[/^nameserver\s+(\S+)/, 1]
      raise "Set CHROMEDRIVER_URL to the remote ChromeDriver URL" unless wsl_host

      "http://#{wsl_host}:9515/"
    end

    Capybara.register_driver :selenium_remote_chrome do |app|
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument("--start-maximized")

      Capybara::Selenium::Driver.new(
        app,
        browser: :remote,
        url: chromedriver_url,
        options: options
      )
    end
    driven_by :selenium_remote_chrome
  end

  register_spec_type(self) do |_description, *addl|
    addl.include? :system
  end

  Capybara.configure do |config|
    # Match what's set for URL options in test.rb so we
    # can test mailers that contain links.
    config.server_host = "localhost"
    config.server_port = "3000"
  end
end
