FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    association :tenant

    trait :with_custom_values do
      custom_field_values {
        { "phone" => "+48123123123", "tags" => ["ruby", "api"] }
      }
    end
  end
end
