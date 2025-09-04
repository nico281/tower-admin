class ResidentInvitationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :accept, :create_account ]
  before_action :find_resident_by_token, only: [ :accept, :create_account ]

  def accept
    if @resident.nil?
      redirect_to root_path, alert: "Invitación inválida o expirada."
      return
    end

    if @resident.invitation_accepted?
      redirect_to root_path, alert: "Esta invitación ya fue aceptada."
      return
    end

    if @resident.user.present?
      redirect_to root_path, alert: "Ya tienes una cuenta creada."
      return
    end

    @user = User.new(
      email: @resident.email,
      role: :resident,
      company: @resident.company,
      resident: @resident
    )
  end

  def create_account
    if @resident.nil?
      redirect_to root_path, alert: "Invitación inválida o expirada."
      return
    end

    @user = User.new(user_params)
    @user.role = :resident
    @user.company = @resident.company
    @user.resident = @resident

    if @user.save
      @resident.update!(invitation_accepted_at: Time.current)
      sign_in(@user)
      redirect_to dashboard_path, notice: "¡Bienvenido! Tu cuenta ha sido creada exitosamente."
    else
      render :accept, status: :unprocessable_entity
    end
  end

  private

  def find_resident_by_token
    token = params[:token]
    @resident = Resident.find_by(invitation_token: token) if token.present?
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
