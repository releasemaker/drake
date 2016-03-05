module Concerns
  module User
    module GithubAccount
      extend ActiveSupport::Concern

      def has_github?
        github_identity.present?
      end

      def github_identity
        @github_identity ||= user_identities.find_by(provider: 'github')
      end

      def github_client(opts={})
        return unless has_github?

        @github_client ||= Github.new oauth_token: github_identity.token
      end
    end
  end
end
