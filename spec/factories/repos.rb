# frozen_string_literal: true

# == Schema Information
#
# Table name: repos
#
#  id                    :bigint           not null, primary key
#  enabled               :boolean
#  name                  :string
#  provider_data         :json
#  provider_uid_or_url   :string
#  provider_webhook_data :json
#  type                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_repos_on_type_and_provider_uid_or_url  (type,provider_uid_or_url) UNIQUE
#
FactoryBot.define do
  factory :repo do
    sequence(:name) { |n| "repo#{n}" }
    enabled { true }
    sequence(:provider_uid_or_url) { |n| "repo#{n}" }

    trait :disabled do
      enabled { false }
    end
  end
end
