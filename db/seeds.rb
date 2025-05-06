User.delete_all
Tenant.delete_all

demo_tenant = Tenant.create!(
  name: "Demo Tenant",
  custom_fields_settings: [
    { "key"    => "phone",
      "label"  => "Phone number",
      "type"   => "number",
      "options"=> [] },
    { "key"    => "bio",
      "label"  => "Biography",
      "type"   => "text",
      "options"=> [] },
    { "key"    => "status",
      "label"  => "Status",
      "type"   => "single_select",
      "options"=> ["active", "inactive"] },
    { "key"    => "tags",
      "label"  => "Tags",
      "type"   => "multi_select",
      "options"=> ["ruby", "rails", "api"] }
  ]
)

User.create!(
  email: "alice@example.com",
  tenant: demo_tenant,
  custom_field_values: {
    "phone"  => "+48123456789",
    "bio"    => "Senior RoR dev",
    "status" => "active",
    "tags"   => ["ruby", "api"]
  }
)

User.create!(
  email: "bob@example.com",
  tenant: demo_tenant,
  custom_field_values: {
    "phone"  => "+48111222333",
    "bio"    => "Junior dev",
    "status" => "inactive",
    "tags"   => ["rails"]
  }
)

puts "Seeded Demo Tenant (ID=#{demo_tenant.id}) with #{demo_tenant.users.count} users."
