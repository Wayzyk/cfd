require 'rails_helper'

RSpec.describe "Tenants API", type: :request do
  let(:tenant) { create(:tenant, :with_custom_fields) }

  let(:valid_payload) do
    {
      tenant: {
        custom_fields_settings: tenant.custom_fields_settings.map { |f| f.transform_keys(&:to_s) }
      }
    }
  end

  describe "PATCH /tenants/:id" do
    context "with valid params" do
      it "updates custom_fields_settings and returns 200" do
        patch "/tenants/#{tenant.id}", params: valid_payload

        expect(response).to have_http_status(:ok)
        tenant.reload
        expect(tenant.custom_fields_settings)
          .to match_array(valid_payload[:tenant][:custom_fields_settings].map(&:symbolize_keys))
      end
    end

    context "with invalid params" do
      it "returns 422 if a field is missing the required key" do
        invalid = {
          tenant: {
            custom_fields_settings: [
              { label: "Phone", type: "number", options: [] }  # missing key
            ]
          }
        }

        patch "/tenants/#{tenant.id}", params: invalid

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"].join).to match(/key/)
      end

      it "returns 422 if custom_fields_settings is not an array" do
        invalid = { tenant: { custom_fields_settings: {} } }
        patch "/tenants/#{tenant.id}", params: invalid

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end