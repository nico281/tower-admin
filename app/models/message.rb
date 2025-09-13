class Message < ApplicationRecord
  acts_as_tenant(:company)

  belongs_to :company
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  validates :body, presence: true

  after_create_commit do
    target_id = ActionView::RecordIdentifier.dom_id(conversation, :messages)
    broadcast_append_to ["conversation", conversation_id], target: target_id, partial: "messages/message", locals: { message: self }
  end
end
