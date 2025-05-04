class AddCustomFieldsSettingsToTenants < ActiveRecord::Migration[7.2]
  def change
    add_column :tenants, :custom_fields_settings, :jsonb, null: false, default: {}
  end
end
