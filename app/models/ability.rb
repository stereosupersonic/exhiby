# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Public access - anyone can read published articles and media items
    can :read, Article, status: "published"
    can :read, MediaItem, status: "published"

    return unless user.present?

    # All authenticated users can access admin area (dashboard) and manage their own profile
    can :manage, :admin_area
    can %i[read update], User, id: user.id

    # All authenticated users can create media items and manage their own
    can :create, MediaItem
    can %i[read update destroy], MediaItem, uploaded_by_id: user.id
    can :submit_for_review, MediaItem, uploaded_by_id: user.id, status: "draft"

    if user.admin?
      can :manage, :all
    elsif user.editor?
      can :manage, :content
      can :manage, :admin_area
      can :manage, Article
      can :manage, MediaItem
      can :manage, MediaTag
      can %i[publish reject unpublish], MediaItem
    end
  end
end
