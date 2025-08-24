class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  set_current_tenant_by_subdomain_or_domain(:company, :subdomain, :domain)
  before_action :skip_tenant_for_super_admin
  allow_browser versions: :modern
  before_action :authenticate_user!

  def skip_tenant_for_super_admin
    AxtAsTenant.current_tenant = nil if current_user&.super_admin?
  end

  def require_super_admin!
    redirect_to root_path, alert: "Not authorized" unless current_user&.super_admin?
  end

  def require_company_admin!
    redirect_to root_path, alert: "Not authorized" unless current_user&.admin?
  end
end
