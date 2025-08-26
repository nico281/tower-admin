class UsersController < ApplicationController
  layout "admin"
  before_action :require_super_admin!
  before_action :set_user, only: %i[ show edit update destroy ]
  
  before_action :log_action

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
    @companies = Company.all
  end

  def create
    Rails.logger.debug "CREATE: Current user: #{current_user&.email}, super_admin: #{current_user&.super_admin?}"
    @user = User.new(user_params)

    if @user.password.blank?
      password = SecureRandom.hex(8)
      @user.password = password
      @user.password_confirmation = password
    end

    Rails.logger.debug "About to save user: #{@user.inspect}"

    respond_to do |format|
      if @user.save
        Rails.logger.debug "User saved successfully"
        format.html { redirect_to @user, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        Rails.logger.debug "User save failed: #{@user.errors.full_messages}"
        @companies = Company.all
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @companies = Company.all
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "User was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        @companies = Company.all
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_path, notice: "User was successfully deleted.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def log_action
    Rails.logger.debug "USERS_CONTROLLER: #{action_name} - subdomain: #{request.subdomain}, method: #{request.method}"
  end

  def set_user
    @user = User.find(params.expect(:id))
  end

  def user_params
    params.expect(user: [ :email, :password, :password_confirmation, :role, :company_id ])
  end
end
