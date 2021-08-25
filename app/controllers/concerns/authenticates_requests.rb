# frozen_string_literal: true

module AuthenticatesRequests
  extend ActiveSupport::Concern

  included do
    # Users must be logged in to the app unless the controller calls {#do_not_require_login}.
    before_action :require_login

    check_authorization
  end

  module ClassMethods
    def do_not_require_login(*options)
      skip_before_action(:require_login, *options)
    end
  end
end
