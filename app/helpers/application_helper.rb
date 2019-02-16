module ApplicationHelper
  def show_navigation?
    !(@disable_navigation || false)
  end

  def github_auth_path
    '/auth/github'
  end
end
