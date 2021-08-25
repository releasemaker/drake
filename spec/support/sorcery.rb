# frozen_string_literal: true

module Sorcery
  module TestHelpers
    module Rails
      module Request
        def login_user(user)
          fail "No credentials on this user" unless user.email && user.crypted_password
          post(sign_in_url, params: {user: {email: user.email, password: "password"}})
          fail "Failed to sign user in" unless response.status == 302
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Sorcery::TestHelpers::Rails
  config.include Sorcery::TestHelpers::Rails::Controller, type: :controller
  config.include Sorcery::TestHelpers::Rails::Integration, type: :feature
  config.include Sorcery::TestHelpers::Rails::Request, type: :request
end
