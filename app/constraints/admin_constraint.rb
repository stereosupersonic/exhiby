# Constraint to check if user is admin for Sidekiq Web UI
class AdminConstraint
  def matches?(request)
    return false unless request.cookie_jar.signed[:session_id]

    session = Session.find_by(id: request.cookie_jar.signed[:session_id])
    session&.user&.active? && session&.user.admin?
  end
end
