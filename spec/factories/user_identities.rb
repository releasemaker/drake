FactoryGirl.define do
  factory :user_identity do
    user
    provider 'github'

    transient do
      sequence(:uid)
      sequence(:nickname) { |n| "nickname#{n}" }
      sequence(:email) { |n| "user#{n}@example.com" }
    end

    after(:build) do |user_identity, evaluator|
      user_identity.data ||= {
        'uid' => evaluator.uid,
        'info' => {
          'nickname' => evaluator.nickname,
          'email' => evaluator.email,
        },
      }
    end
  end
end
