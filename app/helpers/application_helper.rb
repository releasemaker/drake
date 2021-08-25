# frozen_string_literal: true

module ApplicationHelper
  def show_navigation?
    logged_in? && !(@disable_navigation || false)
  end

  def github_auth_path
    '/auth/github'
  end
end
