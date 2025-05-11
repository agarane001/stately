class ReservationsController < ApplicationController
  before_action :set_reservation, only: [ :show, :edit, :update, :destroy, :cancel, :fulfill ]

  def index
    @reservations = policy_scope(Reservation).includes(:book, :member)
  end

  def show
    authorize @reservation
  end

  def new
    @reservation = Reservation.new
    authorize @reservation
  end

  def create
    @reservation = Reservation.new(reservation_params)
    authorize @reservation

    if @reservation.save
      redirect_to @reservation, notice: "Reservation was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @reservation
  end

  def update
    authorize @reservation
    if @reservation.update(reservation_params)
      redirect_to @reservation, notice: "Reservation was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @reservation
    @reservation.destroy
    redirect_to reservations_url, notice: "Reservation was successfully deleted."
  end

  def cancel
    authorize @reservation
    @reservation.update(status: :cancelled)
    redirect_to @reservation, notice: "Reservation was successfully cancelled."
  end

  def fulfill
    authorize @reservation
    if @reservation.fulfill
      redirect_to @reservation, notice: "Reservation was successfully fulfilled."
    else
      redirect_to @reservation, alert: "Could not fulfill the reservation."
    end
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:book_id, :member_id, :reserved_on, :expires_on, :status)
  end
end
