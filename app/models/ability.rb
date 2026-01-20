# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Public access - anyone can read published articles
    can :read, Article, status: "published"

    return unless user.present?

    # All authenticated users can access admin area (dashboard) and manage their own profile
    can :manage, :admin_area
    can %i[read update], User, id: user.id

    if user.admin?
      can :manage, :all
    elsif user.editor?
      can :manage, :content
      can :manage, :admin_area
      can :manage, Article
    end
  end
end
