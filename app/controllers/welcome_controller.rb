class WelcomeController < ApplicationController
  allow_unauthenticated_access

  def index; end

  def impressum; end

  def datenschutzerklaerung; end
end
