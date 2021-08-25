# frozen_string_literal: true

module DisplaysNavigation
  extend ActiveSupport::Concern

  included do
    helper_method :navigation_disabled?
  end

  def disable_navigation
    @disable_navigation = true
  end

  def navigation_disabled?
    @disable_navigation || false
  end
end
