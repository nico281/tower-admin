class CompanyChatChannel < ApplicationCable::Channel
  def subscribed
    return reject unless current_user&.company_id && params[:company_id].to_i == current_user.company_id
    stream_for Company.find(params[:company_id])
  end
end
