class ApartmentsController < ApplicationController
  include Filterable

  layout "tenant"
  before_action :require_company_admin!
  before_action :set_apartment, only: %i[ show edit update destroy ]

  def index
    @pagy, @apartments = filter_and_paginate(Apartment.includes(:building, :residents), {
      search: { term: params[:search], columns: [ :number, :description ] },
      associations: { building_id: params[:building_id] },
      page: params[:page]
    })

    # For filter dropdowns
    @buildings = Building.all
  end

  def show
    @residents = @apartment.residents
  end

  def new
    @apartment = Apartment.new
    @apartment.building_id = params[:building_id] if params[:building_id].present?
    @buildings = Building.all
  end

  def create
    @apartment = Apartment.new(apartment_params)
    @apartment.company = ActsAsTenant.current_tenant

    respond_to do |format|
      if @apartment.save
        format.html { redirect_to @apartment, notice: "Apartment was successfully created." }
        format.json { render :show, status: :created, location: @apartment }
      else
        @buildings = Building.all
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @apartment.errors, status: :unprocessable_content }
      end
    end
  end

  def edit
    @buildings = Building.all
  end

  def update
    respond_to do |format|
      if @apartment.update(apartment_params)
        format.html { redirect_to @apartment, notice: "Apartment was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @apartment }
      else
        @buildings = Building.all
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @apartment.errors, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @apartment.destroy!

    respond_to do |format|
      format.html { redirect_to apartments_path, notice: "Apartment was successfully deleted.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_apartment
    @apartment = Apartment.find(params.expect(:id))
  end

  def apartment_params
    params.expect(apartment: [ :number, :building_id, :floor, :bedrooms, :bathrooms, :size, :description ])
  end
end
