require 'rails_helper'

RSpec.describe CustomFields::ValuesSanitizer, type: :model do
  let(:definitions) do
    [
      { key: :age,    label: 'Age',    type: 'number',        options: [] },
      { key: :status, label: 'Status', type: 'single_select', options: ['active', 'inactive'] },
      { key: :tags,   label: 'Tags',   type: 'multi_select',  options: ['ruby', 'rails'] },
      { key: :bio,    label: 'Bio',    type: 'text',          options: [] }
    ]
  end

  describe '#call' do
    context 'with valid data' do
      let(:raw) do
        {
          'age' => '42',
          'status' => 'active',
          'tags' => ['ruby', 'rails'],
          'bio' => 'Hello world'
        }
      end

      it 'returns the sanitized hash unchanged' do
        result = described_class.new(raw, definitions).call
        expect(result).to eq(raw)
      end
    end

    context 'with raw not a hash' do
      it 'raises validation error for non-hash input' do
        expect { described_class.new('not a hash', definitions).call }
          .to raise_error(ActiveModel::ValidationError) { |e|
            expect(e.model.errors[:base]).to include('custom_field_values must be a hash')
          }
      end
    end

    context 'with unknown field key' do
      let(:raw) { { 'unknown' => 'value' } }

      it 'raises validation error for unknown field' do
        expect { described_class.new(raw, definitions).call }
          .to raise_error(ActiveModel::ValidationError) { |e|
            expect(e.model.errors[:base]).to include("unknown field 'unknown'")
          }
      end
    end

    context 'with invalid number value' do
      let(:raw) { { 'age' => 'abc' } }

      it 'raises validation error for non-numeric' do
        expect { described_class.new(raw, definitions).call }
          .to raise_error(ActiveModel::ValidationError) { |e|
            expect(e.model.errors[:base]).to include('age must be a number')
          }
      end
    end

    context 'with invalid single_select value' do
      let(:raw) { { 'status' => 'paused' } }

      it 'raises validation error for not allowed option' do
        expect { described_class.new(raw, definitions).call }
          .to raise_error(ActiveModel::ValidationError) { |e|
            expect(e.model.errors[:base]).to include('status must be one of active, inactive')
          }
      end
    end

    context 'with non-array multi_select value' do
      let(:raw) { { 'tags' => 'ruby' } }

      it 'raises validation error for wrong type' do
        expect { described_class.new(raw, definitions).call }
          .to raise_error(ActiveModel::ValidationError) { |e|
            expect(e.model.errors[:base]).to include('tags must be an array')
          }
      end
    end

    context 'with invalid multi_select options' do
      let(:raw) { { 'tags' => ['ruby', 'python'] } }

      it 'raises validation error for invalid options' do
        expect { described_class.new(raw, definitions).call }
          .to raise_error(ActiveModel::ValidationError) { |e|
            expect(e.model.errors[:base]).to include('tags has invalid options: python')
          }
      end
    end

    context 'with invalid text value' do
      let(:raw) { { 'bio' => 123 } }

      it 'raises validation error for non-string' do
        expect { described_class.new(raw, definitions).call }
          .to raise_error(ActiveModel::ValidationError) { |e|
            expect(e.model.errors[:base]).to include('bio must be a string')
          }
      end
    end
  end
end
