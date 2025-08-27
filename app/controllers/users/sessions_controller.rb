# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :normalize_params, only: [:create]
  
  # Normalize parameter names for different subdomains
  def normalize_params
    if request.subdomain == 'admin' && params[:admin_user]
      params[:user] = params[:admin_user]
    elsif request.subdomain != 'admin' && params[:tenant_user] 
      params[:user] = params[:tenant_user]
    end
  end

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    # Manual authentication for admin subdomain
    if request.subdomain == 'admin'
      user = User.find_by(email: params.dig(:user, :email) || params.dig(:admin_user, :email))
      if user&.valid_password?(params.dig(:user, :password) || params.dig(:admin_user, :password))
        if user.super_admin?
          sign_in(user)
          redirect_to admin_root_path
          return
        else
          flash[:alert] = "Access denied. Super admin required."
          render :new, status: :unprocessable_entity
          return
        end
      else
        flash[:alert] = "Invalid email or password."
        render :new, status: :unprocessable_entity
        return
      end
    end
    
    # Default Devise behavior for other subdomains
    super do |user|
      # Skip company validation for admin subdomain and super_admin users
      if request.subdomain != 'admin' && !user.super_admin?
        if user.company_id != ActsAsTenant.current_tenant&.id
          sign_out(user)
          flash[:alert] = "You don't belong to this company"
          redirect_to request.subdomain == 'admin' ? new_admin_user_session_path : new_user_session_path and return
        end
      end
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end
end
