# frozen_string_literal: true

class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy

  ALLOWED_TYPES = %w[text number single_select multi_select].freeze

  validate :validate_custom_fields_settings_format

  def custom_fields_settings
    raw = read_attribute(:custom_fields_settings) || []
    raw.map(&:deep_symbolize_keys)
  end

  private

  def validate_custom_fields_settings_format
    raw = read_attribute(:custom_fields_settings)
    return if raw.blank?

    unless raw.is_a?(Array)
      errors.add(:custom_fields_settings, 'must be an array')
      return
    end

    raw.each_with_index do |field, idx|
      unless field.is_a?(Hash)
        errors.add(:custom_fields_settings, "element at index \#{idx} must be an object")
        next
      end

      %w[key label type].each do |attr|
        if field[attr].blank?
          errors.add(:custom_fields_settings, "\#{attr} is required at index \#{idx}")
        end
      end

      if field['type'].present? && !ALLOWED_TYPES.include?(field['type'])
        errors.add(:custom_fields_settings, "invalid type '\#{field['type']}' at index \#{idx}")
      end

      if %w[single_select multi_select].include?(field['type'])
        unless field['options'].is_a?(Array)
          errors.add(:custom_fields_settings, "options must be an array for select types at index \#{idx}")
        end
      else
        if field.key?('options') && field['options'].present?
          errors.add(:custom_fields_settings, "options should be empty for type \#{field['type']} at index \#{idx}")
        end
      end
    end
  end
end