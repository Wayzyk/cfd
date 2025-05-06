class AddCustomFieldValuesToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :custom_field_values, :jsonb, null: false, default: {}
  end
end
