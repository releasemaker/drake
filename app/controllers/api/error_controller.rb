# frozen_string_literal: true

class Api::ErrorController < ApplicationApiController
  do_not_require_login
  skip_authorization_check

  def not_found
    head :not_found
  end

  def server_error
    head :internal_server_error
  end

  def bad_json
    render json: '{"im": "broke",'
  end
end
