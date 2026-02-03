require "rails_helper"
require "capybara/rspec"

RSpec.configure do |config|
  config.include Capybara::RSpecMatchers

  Capybara.default_max_wait_time = 10 # The maximum number of seconds to wait for asynchronous processes to finish.
  Capybara.default_normalize_ws = true # match DOM Elements with text spanning over multiple line

  if ENV["CHROME_URL"]
    Capybara.server_host = "0.0.0.0"
    Capybara.server_port = ENV.fetch("CAPYBARA_SERVER_PORT", 3000).to_i
    Capybara.app_host = "http://app:#{Capybara.server_port}"

    require "selenium/webdriver"

    Capybara.register_driver :selenium_remote do |app|
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument("--disable-dev-shm-usage")
      options.add_argument("--headless=new")
      options.add_argument("--start-maximized")
      options.add_argument("--window-size=1600,1400")
      options.add_argument("--disable-extensions")
      options.add_argument("--no-sandbox")
      options.add_argument("--no-default-browser-check")
      options.add_argument("--disable-gpu")

      Capybara::Selenium::Driver.new(app,
                                     browser: :remote,
                                     url: ENV["CHROME_URL"],
                                     options: options)
    end

    config.before(:each, type: :system) do
      driven_by :rack_test
    end

    config.before(:each, type: :system, js: true) do
      driven_by :selenium_remote
    end

  else

    config.before(:each, type: :system) do
      driven_by :rack_test
    end

    config.before(:each, :js, type: :system) do
      # https://api.rubyonrails.org/v6.0.1/classes/ActionDispatch/SystemTestCase.html#method-c-driven_by
      browser = ENV["SELENIUM_BROWSER"].presence&.to_sym || :headless_chrome
      driven_by :selenium, using: browser, screen_size: [ 1600, 1400 ]
    end
  end
end
