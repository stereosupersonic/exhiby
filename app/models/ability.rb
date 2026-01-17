# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    # All authenticated users can read content and manage their own profile
    can :read, :dashboard
    can %i[read update], User, id: user.id

    if user.admin?
      can :manage, :all
    elsif user.editor?
      can :manage, :content
    end
  end
end
