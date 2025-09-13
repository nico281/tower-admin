class ConversationsController < ApplicationController
  layout "tenant"
  before_action :authenticate_user!
  before_action :set_conversation, only: [ :show ]

  def index
    require_company_admin!
    @pagy, @conversations = pagy(Conversation.includes(:resident).order(updated_at: :desc))
  end

  def show
    unless @conversation.participant?(current_user)
      redirect_to tenant_root_path, alert: "Not authorized"
      return
    end
    @message = Message.new
    @messages = @conversation.messages.includes(:sender).order(:created_at)
  end

  def ensure_for_resident
    require_company_admin!
    # Route is /residents/:id/open_chat (member route), so the param key is :id
    resident = Resident.find(params[:id])
    conversation = Conversation.find_or_create_by!(company: ActsAsTenant.current_tenant, resident: resident)
    redirect_to conversation_path(conversation)
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end
end
