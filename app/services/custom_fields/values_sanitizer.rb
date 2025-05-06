# frozen_string_literal: true

module CustomFields
  class ValuesSanitizer
    include ActiveModel::Model

    attr_accessor :raw, :definitions

    # Define custom validations
    validate :raw_is_hash
    validate :values_match_definitions, if: -> { errors.blank? }

    def initialize(raw, definitions)
      @raw = raw
      # Normalize definitions to symbols for consistent access
      @definitions = Array(definitions).map { |d| d.deep_symbolize_keys }
    end

    def call
      @sanitized = convert_to_hash(raw)  # Convert params to plain hash
      valid?  # Run validations
      raise_validation_error if errors.any?  # Raise if any errors
      @sanitized
    end

    private

    # Ensure raw input is a hash-like structure
    def raw_is_hash
      return if raw.nil? || raw.is_a?(ActionController::Parameters) || raw.is_a?(Hash)
      errors.add(:base, 'custom_field_values must be a hash')
    end

    def values_match_definitions
      # Build a lookup table: key => definition
      defs = @definitions.map { |d| [d[:key].to_s, d] }.to_h

      @sanitized.each do |key, value|
        definition = defs[key]
        if definition.nil?
          errors.add(:base, "unknown field '#{key}'")  # Field not defined in schema
          next
        end

        # Type-specific validation
        case definition[:type]
        when 'number'
          unless numeric?(value)
            errors.add(:base, "#{key} must be a number")
          end
        when 'single_select'
          unless definition[:options].include?(value)
            allowed = definition[:options].join(', ')
            errors.add(:base, "#{key} must be one of #{allowed}")
          end
        when 'multi_select'
          unless value.is_a?(Array)
            errors.add(:base, "#{key} must be an array")
          else
            # Ensure all selected values are valid options
            invalid = value - definition[:options]
            unless invalid.empty?
              errors.add(:base, "#{key} has invalid options: #{invalid.join(', ')}")
            end
          end
        when 'text'
          unless value.is_a?(String)
            errors.add(:base, "#{key} must be a string")
          end
        end
      end
    end

    def convert_to_hash(val)
      return {} unless val.is_a?(ActionController::Parameters) || val.is_a?(Hash)
      val.respond_to?(:to_unsafe_h) ? val.to_unsafe_h : val.to_h
    end

    def numeric?(val)
      val.is_a?(Numeric) || !!(val.to_s =~ /^\+?\d+(?:\.\d+)?$/)  # Regex allows int/float-like strings
    end

    def raise_validation_error
      raise ActiveModel::ValidationError.new(self)
    end
  end
end
