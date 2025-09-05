class TenantUsersController < ApplicationController
  include Filterable

  layout "tenant"
  before_action :require_company_admin!
  before_action :set_user, only: %i[ show edit update destroy ]

  def index
    @users = filter_and_paginate(User.where.not(role: [ "super_admin", "resident" ]), {
      search: { term: params[:search], columns: [ :email ] },
      enums: { role: params[:role] },
      page: params[:page]
    })

    # For filter dropdowns
    @roles = User.roles.keys.reject { |role| role == "super_admin" || role == "resident" }
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.company = ActsAsTenant.current_tenant

    if @user.password.blank?
      password = SecureRandom.hex(8)
      @user.password = password
      @user.password_confirmation = password
    end

    respond_to do |format|
      if @user.save
        format.html { redirect_to tenant_user_path(@user), notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to tenant_user_path(@user), notice: "User was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to tenant_users_path, notice: "User was successfully deleted.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_user
    @user = User.where.not(role: [ "super_admin", "resident" ]).find(params.expect(:id))
  end

  def user_params
    params.expect(user: [ :email, :password, :password_confirmation, :role ])
  end
end
