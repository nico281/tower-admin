class MessagesController < ApplicationController
  layout "tenant"
  before_action :authenticate_user!
  before_action :set_conversation

  def create
    unless @conversation.participant?(current_user)
      redirect_to tenant_root_path, alert: "Not authorized"
      return
    end

    @message = @conversation.messages.new(message_params)
    @message.company = ActsAsTenant.current_tenant
    @message.sender = current_user

    if @message.save
      @conversation.touch
      respond_to do |format|
        # Real-time updates are broadcast from the model callback; no extra stream needed here
        format.turbo_stream { head :ok }
        format.html { redirect_to conversation_path(@conversation) }
      end
    else
      @messages = @conversation.messages.includes(:sender).order(:created_at)
      render "conversations/show", status: :unprocessable_content
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
