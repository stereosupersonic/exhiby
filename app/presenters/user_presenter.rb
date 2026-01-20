class UserPresenter < ApplicationPresenter
  ROLE_BADGE_CLASSES = {
    "admin" => "bg-danger",
    "editor" => "bg-primary",
    "user" => "bg-secondary"
  }.freeze

  STATUS_BADGE_CLASSES = {
    true => "bg-success",
    false => "bg-secondary"
  }.freeze

  def role_badge_class
    ROLE_BADGE_CLASSES.fetch(o.role, "bg-secondary")
  end

  def status_badge_class
    STATUS_BADGE_CLASSES.fetch(o.active, "bg-secondary")
  end

  def status_name
    I18n.t("user_statuses.#{o.active? ? 'active' : 'inactive'}")
  end

  def role_name
    I18n.t("user_roles.#{o.role}")
  end

  def formatted_created_at
    I18n.l(o.created_at, format: :long)
  end

  def formatted_created_at_short
    I18n.l(o.created_at, format: :short)
  end

  def articles_count
    o.articles.size
  end
end
