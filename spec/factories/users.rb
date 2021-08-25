# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id               :bigint           not null, primary key
#  crypted_password :string
#  email            :string
#  name             :string
#  salt             :string
#  super_admin      :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
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
