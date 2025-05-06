require 'rails_helper'

RSpec.describe CustomFields::SettingsValidator, type: :model do
  describe '#call' do
    context 'with valid settings array' do
      let(:valid) do
        [
          { 'key' => 'phone', 'label' => 'Phone', 'type' => 'number', 'options' => [] },
          { 'key' => 'tags',  'label' => 'Tags',  'type' => 'multi_select', 'options' => ['ruby'] }
        ]
      end

      it 'returns sanitized array unchanged' do
        expect(CustomFields::SettingsValidator.new(valid).call).to eq(valid)
      end
    end

    context 'when not an array' do
      it 'raises validation error' do
        expect { CustomFields::SettingsValidator.new('not an array').call }
          .to raise_error(ActiveModel::ValidationError) do |e|
            expect(e.model.errors[:base]).to include('custom_fields_settings must be an array')
          end
      end
    end

    context 'when missing required key' do
      let(:invalid) { [ { 'label' => 'NoKey', 'type' => 'text', 'options' => [] } ] }

      it 'raises validation error for missing key' do
        expect { CustomFields::SettingsValidator.new(invalid).call }
          .to raise_error(ActiveModel::ValidationError) do |e|
            expect(e.model.errors[:base].join)
              .to match(/key is required at index 0/)
          end
      end
    end

    context 'when type is invalid' do
      let(:invalid) { [ { 'key' => 'x', 'label' => 'X', 'type' => 'unknown', 'options' => [] } ] }

      it 'raises validation error for bad type' do
        expect { CustomFields::SettingsValidator.new(invalid).call }
          .to raise_error(ActiveModel::ValidationError) do |e|
            expect(e.model.errors[:base].join)
              .to match(/invalid type 'unknown' at index 0/)
          end
      end
    end
  end
end
