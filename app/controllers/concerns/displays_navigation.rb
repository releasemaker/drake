module DisplaysNavigation
  extend ActiveSupport::Concern

  def disable_navigation
    @disable_navigation = true
  end
end
