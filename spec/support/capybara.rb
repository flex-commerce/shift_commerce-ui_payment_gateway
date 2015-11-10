require "capybara/rspec"
require "capybara-screenshot"
require "capybara-webkit"
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end
Capybara::Screenshot.register_driver(:chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara.configure do |config|
  driver = ENV.key?("TEST_BROWSER") ? ENV["TEST_BROWSER"].to_sym : :webkit
  config.javascript_driver = driver
  config.always_include_port = true
  config.server_port = 23456
  config.default_wait_time = 5
end
