class BuildingsController < ApplicationController
  include Filterable

  layout "tenant"
  before_action :require_company_admin!
  before_action :set_building, only: %i[ show edit update destroy ]

  def index
    @buildings = filter_and_paginate(Building.all, {
      search: { term: params[:search], columns: [ :name, :address ] },
      page: params[:page]
    })
  end

  def show
    @apartments = @building.apartments.includes(:residents)
  end

  def new
    @building = Building.new
  end

  def create
    @building = Building.new(building_params)
    @building.company = ActsAsTenant.current_tenant

    respond_to do |format|
      if @building.save
        format.html { redirect_to @building, notice: "Building was successfully created." }
        format.json { render :show, status: :created, location: @building }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @building.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @building.update(building_params)
        format.html { redirect_to @building, notice: "Building was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @building }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @building.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @building.destroy!

    respond_to do |format|
      format.html { redirect_to buildings_path, notice: "Building was successfully deleted.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_building
    @building = Building.find(params.expect(:id))
  end

  def building_params
    params.expect(building: [ :name, :address, :floors, :description ])
  end
end