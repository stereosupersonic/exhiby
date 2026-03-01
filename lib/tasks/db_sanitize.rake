namespace :db do
  desc "Sanitize production data for local development (reset passwords, clear sessions)"
  task sanitize: :environment do
    abort "This task cannot run in production!" if Rails.env.production?

    puts "Sanitizing database for local development..."

    # Reset all passwords to "password"
    default_digest = BCrypt::Password.create("password")
    user_count = User.update_all(password_digest: default_digest)
    puts "  Reset #{user_count} user passwords to 'password'"

    # Clear all sessions
    session_count = Session.count
    Session.delete_all
    puts "  Cleared #{session_count} sessions"

    # Print admin accounts for easy login
    admins = User.where(role: "admin").pluck(:email_address)
    if admins.any?
      puts ""
      puts "Admin accounts (password: 'password'):"
      admins.each { |email| puts "  - #{email}" }
    end

    puts ""
    puts "Sanitization complete."
  end
end
