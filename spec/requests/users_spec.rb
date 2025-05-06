require 'rails_helper'

RSpec.describe "Users API", type: :request do
  let(:tenant) { create(:tenant, :with_custom_fields) }
  let(:user)   { create(:user, :with_custom_values, tenant: tenant) }

  describe "PATCH /users/:id" do
    context "with valid params" do
      let(:valid_payload) do
        {
          user: {
            custom_field_values: {
              "phone" => "+48123123123",
              "tags"  => ["ruby", "api"]
            }
          }
        }
      end

      it "updates custom_field_values and returns 200" do
        patch "/users/#{user.id}", params: valid_payload
        expect(response).to have_http_status(:ok)

        user.reload
        expect(user.custom_field_values).to eq(valid_payload[:user][:custom_field_values])
      end
    end

    context "with invalid number value" do
      let(:invalid_payload) do
        {
          user: {
            custom_field_values: { "phone" => "not_a_number" }
          }
        }
      end

      it "returns 422 and error message" do
        patch "/users/#{user.id}", params: invalid_payload
        expect(response).to have_http_status(:unprocessable_entity)

        body = JSON.parse(response.body)
        expect(body["errors"].first).to match(/phone must be a number/)
      end
    end

    context "with missing user root" do
      it "returns 400 Bad Request" do
        patch "/users/#{user.id}", params: {}
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "with non-hash custom_field_values" do
      let(:invalid_payload) { { user: { custom_field_values: "oops" } } }

      it "returns 422 and error message" do
        patch "/users/#{user.id}", params: invalid_payload
        expect(response).to have_http_status(:unprocessable_entity)

        body = JSON.parse(response.body)
        expect(body["errors"].first).to match(/custom_field_values must be a hash/)
      end
    end

    context "with single_select invalid value" do
      let(:invalid_payload) do
        {
          user: {
            custom_field_values: { "status" => "paused" }
          }
        }
      end

      it "returns 422 and error message" do
        patch "/users/#{user.id}", params: invalid_payload
        expect(response).to have_http_status(:unprocessable_entity)

        body = JSON.parse(response.body)
        expect(body["errors"].first).to match(/status must be one of/)
      end
    end

    context "with multi_select invalid options" do
      let(:invalid_payload) do
        {
          user: {
            custom_field_values: { "tags" => ["ruby", "python"] }
          }
        }
      end

      it "returns 422 and error message" do
        patch "/users/#{user.id}", params: invalid_payload
        expect(response).to have_http_status(:unprocessable_entity)

        body = JSON.parse(response.body)
        expect(body["errors"].first).to match(/tags has invalid options: python/)
      end
    end
  end
end
