class BookLoansController < ApplicationController
  before_action :set_book_loan, only: [ :show, :edit, :update, :destroy, :return, :extend ]

  def index
    @book_loans = policy_scope(BookLoan).includes(:book, :member)
  end

  def show
    authorize @book_loan
  end

  def new
    @book_loan = BookLoan.new
    @book_loan.borrowed_date = Date.current
    @book_loan.due_date = 2.weeks.from_now.to_date
    @book_loan.book_id = params[:book_id] if params[:book_id]
    authorize @book_loan
  end

  def create
    @book_loan = BookLoan.new(book_loan_params)
    authorize @book_loan

    if BookLoanService.create_loan(@book_loan)
      redirect_to @book_loan, notice: "Book loan was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @book_loan
  end

  def update
    authorize @book_loan
    if @book_loan.update(book_loan_params)
      redirect_to @book_loan, notice: "Book loan was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @book_loan
    @book_loan.destroy
    redirect_to book_loans_url, notice: "Book loan was successfully deleted."
  end

  def return
    authorize @book_loan
    if BookLoanService.return_book(@book_loan)
      redirect_to @book_loan, notice: "Book was successfully returned."
    else
      redirect_to @book_loan, alert: "Could not return the book."
    end
  end

  def extend
    authorize @book_loan
    if BookLoanService.extend_loan(@book_loan)
      redirect_to @book_loan, notice: "Loan was successfully extended."
    else
      redirect_to @book_loan, alert: "Could not extend the loan."
    end
  end

  private

  def set_book_loan
    @book_loan = BookLoan.find(params[:id])
  end

  def book_loan_params
    params.require(:book_loan).permit(:book_id, :member_id, :due_date, :borrowed_date)
  end
end
