module Concerns
  module User
    # Contains functionality for a {::User} to interact with Github's API.
    module GithubAccount
      extend ActiveSupport::Concern

      # Determines whether the user has a linked Github account.
      def has_github?
        github_identity.present?
      end

      # Returns the user's linked Github account as a {UserIdentity} record (or nil).
      def github_identity
        @github_identity ||= user_identities.find_by(provider: 'github')
      end

      # Creates a Github API client object that will have the user's API token.
      # Returns nil if the user has no Github account.
      def github_client(opts={})
        return unless has_github?

        @github_client ||= Github.new oauth_token: github_identity.token
      end
    end
  end
end
