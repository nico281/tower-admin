class ResidentsController < ApplicationController
  include Filterable

  layout "tenant"
  before_action :require_company_admin!
  before_action :set_resident, only: %i[ show edit update destroy invite ]

  def index
    @residents = Resident.includes(apartment: :building)

    # Apply search filter
    if params[:search].present?
      @residents = @residents.where("email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR phone ILIKE ?",
                                    "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    # Apply apartment filter
    if params[:apartment_id].present?
      @residents = @residents.where(apartment_id: params[:apartment_id])
    end

    # Apply building filter (through apartments)
    if params[:building_id].present?
      @residents = @residents.joins(:apartment).where(apartments: { building_id: params[:building_id] })
    end

    # Apply pagination
    @pagy, @residents = pagy(@residents)

    # For filter dropdowns
    @apartments = Apartment.includes(:building).all
    @buildings = Building.all
  end

  def show
    @payments = @resident.payments.order(created_at: :desc)
  end

  def new
    @resident = Resident.new
    @resident.apartment_id = params[:apartment_id] if params[:apartment_id].present?
    @apartments = Apartment.includes(:building).all
  end

  def create
    @resident = Resident.new(resident_params)
    @resident.company = ActsAsTenant.current_tenant

    respond_to do |format|
      if @resident.save
        format.html { redirect_to @resident, notice: "Resident was successfully created." }
        format.json { render :show, status: :created, location: @resident }
      else
        @apartments = Apartment.includes(:building).all
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @resident.errors, status: :unprocessable_content }
      end
    end
  end

  def edit
    @apartments = Apartment.includes(:building).all
  end

  def update
    respond_to do |format|
      if @resident.update(resident_params)
        format.html { redirect_to @resident, notice: "Resident was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @resident }
      else
        @apartments = Apartment.includes(:building).all
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @resident.errors, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @resident.destroy!

    respond_to do |format|
      format.html { redirect_to residents_path, notice: "Resident was successfully deleted.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def invite
    if @resident.user.present?
      redirect_to @resident, alert: "El residente ya tiene una cuenta creada."
      return
    end

    if @resident.invitation_pending?
      redirect_to @resident, alert: "El residente ya tiene una invitación pendiente."
      return
    end

    @resident.generate_invitation_token!
    ResidentMailer.invitation(@resident).deliver_now

    redirect_to @resident, notice: "Invitación enviada exitosamente a #{@resident.email}"
  end

  private

  def set_resident
    @resident = Resident.find(params.expect(:id))
  end

  def resident_params
    params.expect(resident: [ :first_name, :last_name, :email, :phone, :apartment_id, :date_of_birth, :emergency_contact, :notes ])
  end
end
