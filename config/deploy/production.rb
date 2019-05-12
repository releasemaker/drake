# frozen_string_literal: true

server "web01.do.rndsvc.net", roles: %w[app web db], user: fetch(:user)
