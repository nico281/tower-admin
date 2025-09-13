class ConversationPolicy
  def initialize(user, conversation)
    @user = user
    @conversation = conversation
  end

  def show?
    conversation.participant?(user)
  end

  private

  attr_reader :user, :conversation
end
