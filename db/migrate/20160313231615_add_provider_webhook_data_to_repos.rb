# frozen_string_literal: true

class AddProviderWebhookDataToRepos < ActiveRecord::Migration[5.1]
  def change
    add_column :repos, :provider_webhook_data, :json
  end
end
