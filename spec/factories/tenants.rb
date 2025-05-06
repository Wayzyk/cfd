FactoryBot.define do
  factory :tenant do
    sequence(:name) { |n| "Tenant #{n}" }

    trait :with_custom_fields do
      custom_fields_settings {
        [
          {
            "key"     => "phone",
            "label"   => "Phone",
            "type"    => "number",
            "options" => []
          },
          {
            "key"     => "status",
            "label"   => "Status",
            "type"    => "single_select",
            "options" => ["active", "inactive"]
          },
          {
            "key"     => "tags",
            "label"   => "Tags",
            "type"    => "multi_select",
            "options" => ["ruby", "rails", "api"]
          }
        ]
      }
    end
  end
end
