class GithubWebhooksController < ActionController::API
  include GithubWebhook::Processor

  def github_push(payload)
    binding.pry
  end

  private

  def webhook_secret(payload)
    ENV['GITHUB_WEBHOOK_SECRET']
  end
end
