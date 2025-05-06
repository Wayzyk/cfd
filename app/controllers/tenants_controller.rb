# frozen_string_literal: true

class TenantsController < ApplicationController
  before_action :set_tenant

  def update
    if @tenant.update(tenant_params)
      render json: @tenant, status: :ok
    else
      render json: { errors: @tenant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_tenant
    @tenant = Tenant.find(params[:id])
  end

  def tenant_params
    params.require(:tenant)
          .permit(custom_fields_settings: [
            :key,
            :label,
            :type,
            { options: [] }
          ])
  end
end
