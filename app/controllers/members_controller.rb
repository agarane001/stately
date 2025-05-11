class MembersController < ApplicationController
  before_action :set_member, only: [ :show, :edit, :update, :destroy, :loans, :reservations ]

  def index
    @members = policy_scope(Member)
  end

  def show
    authorize @member
    @current_loans = @member.book_loans.where(returned_date: nil)
    @past_loans = @member.book_loans.where.not(returned_date: nil).limit(5)
    @reservations = @member.reservations.active
  end

  def new
    @member = Member.new
    authorize @member
  end

  def edit
    authorize @member
  end

  def create
    @member = Member.new(member_params)
    authorize @member

    if @member.save
      redirect_to @member, notice: "Member was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @member
    if @member.update(member_params)
      redirect_to @member, notice: "Member was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @member
    if @member.book_loans.where(returned_date: nil).exists?
      redirect_to @member, alert: "Cannot delete member with active loans."
    else
      @member.destroy
      redirect_to members_url, notice: "Member was successfully deleted."
    end
  end

  def loans
    authorize @member
    @loans = @member.book_loans.includes(:book).order(borrowed_date: :desc)
  end

  def reservations
    authorize @member
    @reservations = @member.reservations.includes(:book).order(reserved_on: :desc)
  end

  private

  def set_member
    @member = Member.find(params[:id])
  end

  def member_params
    params.require(:member).permit(:name, :email, :member_number, :status, :phone, :address)
  end
end
