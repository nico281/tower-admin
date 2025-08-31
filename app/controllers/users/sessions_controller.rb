# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user!
  before_action :normalize_params, only: [ :create ]

  # Normalize parameter names for different subdomains
  def normalize_params
    if request.subdomain == "admin" && params[:admin_user]
      params[:user] = params[:admin_user]
    elsif request.subdomain != "admin" && params[:tenant_user]
      params[:user] = params[:tenant_user]
    end
  end

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    Rails.logger.debug "LOGIN DEBUG: subdomain=#{request.subdomain}, email=#{params.dig(:user, :email)}"
    super
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  protected

  def after_sign_in_path_for(resource)
    if request.subdomain == "admin"
      if resource.super_admin?
        admin_root_path
      else
        # Sign out non-super-admin users immediately
        sign_out resource
        flash[:alert] = "Access denied. Only super admin users can access this area."
        new_user_session_path
      end
    else
      tenant_root_path
    end
  end
end
