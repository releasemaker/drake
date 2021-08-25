# frozen_string_literal: true

module ApplicationHelper
  def show_navigation?
    logged_in? && !navigation_disabled?
  end

  def github_auth_path
    '/auth/github'
  end
end
