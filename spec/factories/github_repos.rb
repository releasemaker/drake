FactoryGirl.define do
  factory :github_repo do
    sequence(:name) { |n| "Repo#{n}" }
    enabled true
    sequence(:provider_uid_or_url) { |n| "githubrepo#{n}" }

    trait :disabled do
      enabled false
    end
  end
end
