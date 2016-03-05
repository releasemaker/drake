FactoryGirl.define do
  factory :repo_membership do
    repo
    user
    write false
    admin false

    trait :write do
      write true
    end

    trait :admin do
      write true
      admin true
    end
  end
end
