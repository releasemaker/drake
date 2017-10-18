class ApplicationController < ActionController::Base
  include Concerns::Navigation

  protect_from_forgery with: :exception

  # Users must be logged in to the app unless the controller calls {#do_not_require_login}.
  before_action :require_login

  check_authorization

  class << self
    def do_not_require_login(*options)
      skip_before_action(:require_login, *options)
    end
  end

  def not_authenticated
    redirect_to sign_in_url
  end
end
