# frozen_string_literal: true

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
