class CompaniesController < ApplicationController
  include Filterable

  layout "admin"
  before_action :require_super_admin!
  before_action :set_company, only: %i[ show edit update destroy ]

  # GET /companies or /companies.json
  def index
    @companies = filter_and_paginate(Company.all, {
      search: { term: params[:search], columns: [ :name, :domain ] },
      enums: { plan: params[:plan] },
      page: params[:page]
    })

    # For filter dropdowns
    @plans = Company.plans.keys
  end

  # GET /companies/1 or /companies/1.json
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies or /companies.json
  def create
    @company = Company.new

    respond_to do |format|
      begin
        @company.assign_attributes(company_params)
        if @company.save
          format.html { redirect_to @company, notice: "Company was successfully created." }
          format.json { render :show, status: :created, location: @company }
        else
          format.html { render :new, status: :unprocessable_content }
          format.json { render json: @company.errors, status: :unprocessable_content }
        end
      rescue ArgumentError => e
        @company.errors.add(:base, e.message)
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @company.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /companies/1 or /companies/1.json
  def update
    respond_to do |format|
      begin
        if @company.update(company_params)
          format.html { redirect_to @company, notice: "Company was successfully updated.", status: :see_other }
          format.json { render :show, status: :ok, location: @company }
        else
          format.html { render :edit, status: :unprocessable_content }
          format.json { render json: @company.errors, status: :unprocessable_content }
        end
      rescue ArgumentError => e
        @company.errors.add(:base, e.message)
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @company.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /companies/1 or /companies/1.json
  def destroy
    @company.destroy!

    respond_to do |format|
      format.html { redirect_to companies_path, notice: "Company was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def company_params
      params.expect(company: [ :name, :plan, :max_buildings, :domain, :subdomain ])
    end
end
