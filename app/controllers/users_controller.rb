# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user  # Load the user before performing any action

  def update
    begin
      # Ensure the "user" param is present, otherwise return a 400 Bad Request
      user_body = params.require(:user)
    rescue ActionController::ParameterMissing => e
      return render json: { errors: [e.message] }, status: :bad_request
    end

    raw_values = user_body[:custom_field_values]

    begin
      # Get custom field definitions from the user's tenant
      definitions = @user.tenant.custom_fields_settings
      # Validate and sanitize the provided custom field values
      sanitized  = CustomFields::ValuesSanitizer.new(raw_values, definitions).call
    rescue ActiveModel::ValidationError => e
      # Return validation errors if sanitization fails
      return render json: { errors: e.model.errors.full_messages },
                    status: :unprocessable_entity
    end

    # Attempt to update the user with sanitized values
    if @user.update(custom_field_values: sanitized)
      render json: @user, status: :ok
    else
      # Return model-level errors if update fails
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])  # Find user by ID from params
  end
end
