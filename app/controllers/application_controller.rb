class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  set_current_tenant_by_subdomain_or_domain(:company, :subdomain, :domain)
  before_action :skip_tenant_for_super_admin
  allow_browser versions: :modern
  before_action :authenticate_user!

  include Pagy::Backend

  def skip_tenant_for_super_admin
  ActsAsTenant.current_tenant = nil if request.subdomain == "admin"
  end

  def require_super_admin!
    unless current_user&.super_admin?
      if request.subdomain == "admin"
        redirect_to new_user_session_path, alert: "Access denied. Super admin privileges required."
      else
        redirect_to tenant_root_path, alert: "Not authorized"
      end
    end
  end

  def require_company_admin!
    redirect_to (request.subdomain == "admin" ? admin_root_path : tenant_root_path), alert: "Not authorized" unless current_user&.admin?
  end

  protected

  def authenticate_user!
    Rails.logger.debug "AUTH DEBUG: subdomain=#{request.subdomain}, user_signed_in?=#{user_signed_in?}, current_user=#{current_user&.email}"
    if request.subdomain == "admin"
      redirect_to new_user_session_path unless user_signed_in?
    else
      super
    end
  end
end
