module AuthenticationHelper
  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password" }
  end

  def sign_in_as(user)
    visit new_session_path
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
  config.include AuthenticationHelper, type: :system
end
