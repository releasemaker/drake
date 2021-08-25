# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    super_admin { false }

    trait :super_admin do
      super_admin { true }
    end

    trait :with_credentials do
      email { generate(:email) }
      password { "password" }
    end
  end
end
