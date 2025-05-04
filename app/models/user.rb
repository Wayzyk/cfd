# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :tenant

  def custom_field_values
    super || {}
  end

  def custom_value(key)
    custom_field_values[key.to_s]
  end

  def set_custom_value(key, value)
    self.custom_field_values = custom_field_values.merge(key.to_s => value)
    self
  end
end
