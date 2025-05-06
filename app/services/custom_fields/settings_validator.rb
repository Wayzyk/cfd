# frozen_string_literal: true

module CustomFields
  class SettingsValidator
    include ActiveModel::Model

    attr_accessor :raw

    def initialize(raw)
      @raw = raw
      super()
    end

    def call
      # Ensure input is an array or nil; otherwise raise a validation error
      if raw.present? && !raw.is_a?(Array)
        errors.add(:base, 'custom_fields_settings must be an array')
        raise_validation_error
      end

      # Normalize each field and clean up empty select options
      @sanitized = Array(raw).map.with_index do |field, idx|
        h = field.respond_to?(:to_unsafe_h) ? field.to_unsafe_h : field.to_h
        if h['options'].is_a?(Array) && h['options'].size == 1 && h['options'].first.blank?
          h['options'] = []  # Convert single blank option to empty array
        end
        h
      end

      validate_contents  # Run field-level validations
      raise_validation_error if errors.any?  # Raise if any validation errors collected
      @sanitized
    end

    private

    def validate_contents
      sanitized.each_with_index do |field, idx|
        unless field.is_a?(Hash)
          errors.add(:base, "element at index #{idx} must be an object")
          next
        end

        # Ensure required attributes are present
        %w[key label type].each do |attr|
          errors.add(:base, "#{attr} is required at index #{idx}") if field[attr].blank?
        end

        type = field['type']
        # Check if type is one of the allowed types
        if type.present? && !Tenant::ALLOWED_TYPES.include?(type)
          errors.add(:base, "invalid type '#{type}' at index #{idx}")
        end

        # Validate 'options' only for select types
        if %w[single_select multi_select].include?(type)
          unless field['options'].is_a?(Array)
            errors.add(:base, "options must be an array for select types at index #{idx}")
          end
        # For non-select types, 'options' should be empty if present
        elsif field.key?('options') && field['options'].present?
          errors.add(:base, "options should be empty for type #{type} at index #{idx}")
        end
      end
    end

    def sanitized
      @sanitized || []
    end

    def raise_validation_error
      raise ActiveModel::ValidationError.new(self)
    end
  end
end
