class AddGinIndexesToCustomFields < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :tenants,
              :custom_fields_settings,
              using: :gin,
              name: "index_tenants_on_custom_fields_settings",
              algorithm: :concurrently

    add_index :users,
              :custom_field_values,
              using: :gin,
              name: "index_users_on_custom_field_values",
              algorithm: :concurrently          
  end
end
