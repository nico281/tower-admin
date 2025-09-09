class NotificationsController < ApplicationController
  include Filterable

  layout "tenant"
  before_action :require_company_admin!
  before_action :set_notification, only: [ :show ]
  before_action :load_buildings, only: [ :new, :create ]

  def index
    @pagy, @notifications = filter_and_paginate(Notification.recent, {
      search: { term: params[:search], columns: [ :title ] },
      enums: {
        notification_type: params[:notification_type],
        priority: params[:priority]
      },
      page: params[:page]
    })

    # For filter dropdowns
    @notification_types = Notification.notification_types.keys
    @priorities = Notification.priorities.keys
  end

  def show
  end

  def new
    @notification = Notification.new
  end

  def create
    Rails.logger.debug "NOTIFICATION CREATE DEBUG:"
    Rails.logger.debug "  ALL PARAMS: #{params.inspect}"
    Rails.logger.debug "  target_type: #{params[:target_type]}"
    Rails.logger.debug "  target_id: #{params[:target_id]}"
    Rails.logger.debug "  notification_params: #{notification_params}"

    @notification = Notification.new(notification_params)
    @notification.sender = current_user
    @notification.company = ActsAsTenant.current_tenant

    # Determine target based on form selection
    target = determine_target
    Rails.logger.debug "  determined target: #{target.inspect}"

    # Set the target on the notification object
    @notification.target = target if target
    Rails.logger.debug "  notification target set to: #{@notification.target.inspect}"

    if target && @notification.valid?
      case params[:target_type]
      when "building"
        NotificationService.send_to_building(target, notification_params, current_user)
      when "apartment"
        NotificationService.send_to_apartment(target, notification_params, current_user)
      when "all_buildings"
        NotificationService.send_to_all_buildings(ActsAsTenant.current_tenant, notification_params, current_user)
      end

      redirect_to notifications_path, notice: "Notification sent successfully to #{target&.class&.name || 'all buildings'}!"
    else
      Rails.logger.debug "  validation failed - target: #{target.inspect}, notification valid: #{@notification.valid?}"
      Rails.logger.debug "  notification errors: #{@notification.errors.full_messages}"
      @notification.errors.add(:target, "must be selected") unless target
      load_buildings
      render :new, status: :unprocessable_content
    end
  end

  def apartments_for_building
    building_id = params[:building_id]
    apartments = Apartment.where(building_id: building_id).order(:id)

    options = apartments.map do |apartment|
      { id: apartment.id, name: "Apartment #{apartment.id}" }
    end

    render json: options
  end

  private

  def set_notification
    @notification = Notification.find(params[:id])
  end

  def load_buildings
    @buildings = Building.all.order(:name)
    @apartments = Apartment.joins(:building).order("buildings.name, apartments.id")
  end

  def notification_params
    params.require(:notification).permit(:title, :message, :notification_type, :priority)
  end

  def determine_target
    Rails.logger.debug "  determine_target called with target_type: #{params[:target_type]}"
    case params[:target_type]
    when "building"
      target = Building.find(params[:target_id]) if params[:target_id].present?
      Rails.logger.debug "    building target: #{target.inspect}"
      target
    when "apartment"
      target = Apartment.find(params[:target_id]) if params[:target_id].present?
      Rails.logger.debug "    apartment target: #{target.inspect}"
      target
    when "all_buildings"
      target = ActsAsTenant.current_tenant
      Rails.logger.debug "    all_buildings target: #{target.inspect}"
      target
    else
      Rails.logger.debug "    unknown target_type: #{params[:target_type]}"
      nil
    end
  end
end
