# frozen_string_literal: true

class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy

  def custom_fields
    custom_fields_settings || []
  end

  def find_field!(key)
    custom_fields.find { |f| f["key"] == key } or
      raise ActiveRecord::RecordNotFound, "Field #{key} not found"
  end
end
