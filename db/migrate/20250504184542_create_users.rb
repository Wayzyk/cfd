class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
