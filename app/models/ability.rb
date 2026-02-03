# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Public access - anyone can read published articles, media items, artists, and collections
    can :read, Article, status: "published"
    can :read, MediaItem, status: "published"
    can :read, Artist, status: "published"
    can :read, Collection, status: "published"
    can :read, CollectionCategory
    can :read, PictureOfTheDay

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
      can :manage, Technique
      can :manage, Artist
      can :manage, CollectionCategory
      can :manage, Collection
      can :manage, CollectionItem
      can :manage, PictureOfTheDay
      can %i[publish reject unpublish], MediaItem
      can %i[publish unpublish], Artist
      can %i[publish unpublish], Collection
    end
  end
end
