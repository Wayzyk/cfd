# frozen_string_literal: true

class TenantsController < ApplicationController
  before_action :set_tenant  # Load the tenant before performing any action

  def update
    tenant_body  = params[:tenant] if params[:tenant].is_a?(ActionController::Parameters)
    raw_settings = tenant_body && tenant_body[:custom_fields_settings]

    # Ensure the custom_fields_settings is an array, otherwise return an error
    unless raw_settings.is_a?(Array)
      return render json: { errors: ['custom_fields_settings must be an array'] },
                    status: :unprocessable_entity
    end

    begin
      # Validate and sanitize the incoming custom fields settings
      sanitized = CustomFields::SettingsValidator.new(raw_settings).call
    rescue ActiveModel::ValidationError => e
      # Return validation errors if sanitization fails
      return render json: { errors: e.model.errors.full_messages },
                    status: :unprocessable_entity
    end

    # Attempt to update the tenant with sanitized settings
    if @tenant.update(custom_fields_settings: sanitized)
      render json: @tenant, status: :ok
    else
      # Return model-level errors if update fails
      render json: { errors: @tenant.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

  def set_tenant
    @tenant = Tenant.find(params[:id])  # Find tenant by ID from params
  end
end
