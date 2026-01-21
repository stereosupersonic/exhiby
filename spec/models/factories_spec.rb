require "rails_helper"

RSpec.describe "Factories" do
  it "all factories can be created" do
    FactoryBot.lint traits: true
    expect(true).to be true
  end
end
