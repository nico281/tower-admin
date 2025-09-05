class ResidentNotificationsController < ApplicationController
  include Filterable
  
  layout "tenant"
  before_action :authenticate_user!
  before_action :ensure_resident_user!
  before_action :set_notification_recipient, only: [:show, :mark_as_read]

  def index
    Rails.logger.info "=== RESIDENT NOTIFICATIONS INDEX ==="
    Rails.logger.info "Current user: #{current_user&.id} (#{current_user&.email}) - Role: #{current_user&.role}"
    Rails.logger.info "Current user resident: #{current_user&.resident&.id} (#{current_user&.resident&.email})"
    Rails.logger.info "Request subdomain: #{request.subdomain}"
    
    # Get notifications for the current resident
    if current_user&.resident
      all_recipients = current_user.resident.notification_recipients.joins(:notification).order('notifications.created_at DESC')
      Rails.logger.info "Found #{all_recipients.count} notification recipients"
      
      @notification_recipients = filter_and_paginate(all_recipients, {
        page: params[:page]
      })
      
      # Fallback if filter_and_paginate fails
      if @notification_recipients.nil?
        Rails.logger.warn "filter_and_paginate returned nil, using simple pagination"
        @notification_recipients = all_recipients.limit(10)
      end
      
      Rails.logger.info "After pagination: #{@notification_recipients.count} recipients"
      Rails.logger.info "Sample notifications: #{@notification_recipients.limit(2).map { |nr| nr.notification.title }.join(', ')}"
    else
      @notification_recipients = []
      Rails.logger.error "No resident found for current user!"
    end
    
    # Mark the page view (could be used for analytics)
    Rails.logger.info "Resident #{current_user.resident&.id} viewed notifications"
    Rails.logger.info "=== END RESIDENT NOTIFICATIONS INDEX ==="
  end

  def show
    # Mark as read when viewed
    @notification_recipient.mark_as_read! if @notification_recipient.unread?
    
    @notification = @notification_recipient.notification
  end

  def mark_as_read
    Rails.logger.info "=== MARK AS READ ACTION ==="
    Rails.logger.info "Current user: #{current_user&.id} (#{current_user&.email})"
    Rails.logger.info "Notification recipient ID: #{params[:id]}"
    Rails.logger.info "Notification recipient: #{@notification_recipient.inspect}"
    Rails.logger.info "Current read status: #{@notification_recipient.read?}"
    
    if @notification_recipient.read?
      Rails.logger.info "Already marked as read, redirecting"
      redirect_back(fallback_location: resident_notifications_path, notice: "Notification was already marked as read.")
      return
    end
    
    begin
      @notification_recipient.mark_as_read!
      Rails.logger.info "Successfully marked notification #{@notification_recipient.id} as read"
      redirect_back(fallback_location: resident_notifications_path, notice: "Notification marked as read.")
    rescue => e
      Rails.logger.error "Error marking notification as read: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.first(10).join("\n")}"
      redirect_back(fallback_location: resident_notifications_path, alert: "Error marking notification as read: #{e.message}")
    end
    
    Rails.logger.info "=== END MARK AS READ ACTION ==="
  end

  private

  def ensure_resident_user!
    unless current_user&.resident?
      redirect_to tenant_root_path, alert: "Access denied. Resident access required."
    end
  end

  def set_notification_recipient
    @notification_recipient = current_user.resident.notification_recipients.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to resident_notifications_path, alert: "Notification not found."
  end
end
