FactoryGirl.define do
  factory :user_identity do
    user
    provider 'github'

    transient do
      sequence(:uid)
      sequence(:nickname) { |n| "nickname#{n}" }
      sequence(:email) { |n| "user#{n}@example.com" }
      sequence(:token) { |n| "token#{n}" }
    end

    trait :github do
      provider 'github'
    end

    after(:build) do |user_identity, evaluator|
      user_identity.data ||= {
        'uid' => evaluator.uid,
        'info' => {
          'nickname' => evaluator.nickname,
          'email' => evaluator.email,
        },
        'credentials' => {
          'token' => evaluator.token,
        },
      }
    end
  end
end
