class DashboardController < ApplicationController
  layout "tenant"
  before_action :require_company_admin!

  def index
    @company = ActsAsTenant.current_tenant
    @buildings_count = Building.count
    @apartments_count = Apartment.count
    @users_count = User.count
    @recent_buildings = Building.order(created_at: :desc).limit(5)
    @recent_users = User.order(created_at: :desc).limit(5)
  end
end