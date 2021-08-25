# frozen_string_literal: true

class RepoProviderWebhookService
  def initialize(repo)
    @repo = repo
  end

  def perform!
    if repo.enabled? && repo.provider_webhook_data.blank?
      add_to_provider
    elsif !repo.enabled && repo.provider_webhook_data.present?
      remove_from_provider
    end
  end

  private

  attr_reader :repo

  def add_to_provider
    webhook_data = repo.github_client.repos.hooks.create(
      repo.owner_name,
      repo.repo_name,
      name: "web",
      events: %w[push pull_request],
      active: true,
      config: {
        url: webhook_url,
        content_type: 'json',
        secret: Rails.configuration.x.github.webhook_secret,
      },
    )
    repo.update! provider_webhook_data: webhook_data.to_h
  end

  def webhook_url
    Rails.application.routes.url_helpers.github_webhooks_url(
      type: 'repo',
      id: repo.id,
      host: Rails.configuration.x.webhooks.host,
      protocol: Rails.configuration.x.webhooks.protocol,
    )
  end

  def remove_from_provider
    begin
      repo.github_client.repos.hooks.delete(
        repo.owner_name,
        repo.repo_name,
        repo.provider_webhook_data.id,
      )
    rescue Github::Error::NotFound
      nil
    end
    repo.update! provider_webhook_data: nil
  end
end
