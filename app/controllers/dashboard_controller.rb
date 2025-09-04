class DashboardController < ApplicationController
  layout "tenant"

  def index
    @company = ActsAsTenant.current_tenant

    if current_user.resident?
      render_resident_dashboard
    else
      require_company_admin_access!
      render_admin_dashboard
    end
  end

  private

  def render_resident_dashboard
    @resident = current_user.resident
    @building = @resident.building
    @apartment = @resident.apartment
    @recent_payments = @resident.payments.order(created_at: :desc).limit(5)
    @pending_payments = @resident.payments.pending.order(created_at: :desc).limit(3)
    render :resident_index
  end

  def render_admin_dashboard
    @buildings_count = Building.count
    @apartments_count = Apartment.count
    @users_count = User.count
    @recent_buildings = Building.order(created_at: :desc).limit(5)
    @recent_users = User.order(created_at: :desc).limit(5)
    render :index
  end

  def require_company_admin_access!
    unless current_user&.admin?
      redirect_to tenant_root_path, alert: "Not authorized"
    end
  end
end
