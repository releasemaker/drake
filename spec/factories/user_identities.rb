# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identities
#
#  id         :bigint           not null, primary key
#  data       :json
#  provider   :string
#  uid        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_user_identities_on_provider_and_uid      (provider,uid) UNIQUE
#  index_user_identities_on_user_id               (user_id)
#  index_user_identities_on_user_id_and_provider  (user_id,provider) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :user_identity do
    user
    provider { 'github' }

    transient do
      sequence(:uid)
      sequence(:nickname) { |n| "nickname#{n}" }
      sequence(:email) { |n| "user#{n}@example.com" }
      sequence(:token) { |n| "token#{n}" }
    end

    trait :github do
      provider { 'github' }
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
