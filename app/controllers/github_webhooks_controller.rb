# Handles webhooks sent by Github.
class GithubWebhooksController < ApplicationApiController
  include GithubWebhook::Processor
  do_not_require_login
  skip_authorization_check

  rescue_from ::GithubWebhook::Processor::SignatureError, with: :signature_error

  def github_pull_request(payload)
    PullRequestHandler.new(hook_payload: payload).handle!
  end

  def github_push(payload)
    # Do nothing.
  end

  def signature_error
    render plain: "Signature mismatch", status: :forbidden
  end

  private

  def webhook_secret(_payload)
    Rails.configuration.x.github.webhook_secret
  end
end
