class ResidentConversationsController < ApplicationController
  layout "tenant"
  before_action :authenticate_user!

  def show
    unless current_user&.resident?
      redirect_to tenant_root_path, alert: "Not authorized"
      return
    end
    @conversation = Conversation.find_or_create_by!(resident_id: current_user.resident_id, company: ActsAsTenant.current_tenant)
    @message = Message.new
    @messages = @conversation.messages.includes(:sender).order(:created_at)
    render "conversations/show"
  end
end
