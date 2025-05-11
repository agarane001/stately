# frozen_string_literal: true

class BookLoanService
  class Result
    attr_reader :success, :message, :data

    def initialize(success:, message:, data: nil)
      @success = success
      @message = message
      @data = data
    end

    def success?
      @success
    end
  end

  def initialize(book:, member:)
    @book = book
    @member = member
  end

  # Attempts to borrow a book for a member
  def borrow_book
    return error_result("Member is not active") unless @member.active?
    return error_result("Book is not available for borrowing") unless can_borrow_book?
    return error_result("Member has reached maximum allowed loans") if max_loans_reached?
    return error_result("Member has overdue books") if has_overdue_books?

    loan = create_loan
    if loan.save
      handle_successful_loan(loan)
    else
      error_result(loan.errors.full_messages.to_sentence)
    end
  end

  # Attempts to reserve a book for a member
  def reserve_book
    return error_result("Member is not active") unless @member.active?
    return error_result("Book cannot be reserved") unless can_reserve_book?
    return error_result("Member has reached maximum reservations") if max_reservations_reached?
    return error_result("Member already has this book reserved") if already_reserved?

    reservation = create_reservation
    if reservation.save
      handle_successful_reservation(reservation)
    else
      error_result(reservation.errors.full_messages.to_sentence)
    end
  end

  # Handles returning a book
  def return_book(book_loan)
    return error_result("Book loan not found") unless book_loan
    return error_result("Book already returned") if book_loan.returned?

    ActiveRecord::Base.transaction do
      book_loan.returned_date = Date.current
      book_loan.status = :returned

      if book_loan.save
        handle_book_return(book_loan)
      else
        return error_result(book_loan.errors.full_messages.to_sentence)
      end
    end

    success_result("Book successfully returned", book_loan)
  end

  # Checks if a book can be borrowed
  def can_borrow_book?
    @book.available? && !max_loans_reached? && !has_overdue_books?
  end

  # Checks if a book can be reserved
  def can_reserve_book?
    (@book.borrowed? || @book.available?) &&
      !max_reservations_reached? &&
      !already_reserved?
  end

  private

  def create_loan
    BookLoan.new(
      book: @book,
      member: @member,
      borrowed_date: Date.current,
      due_date: 2.weeks.from_now.to_date,
      status: :active
    )
  end

  def create_reservation
    Reservation.new(
      book: @book,
      member: @member,
      reserved_on: Date.current,
      expiry_date: 1.week.from_now.to_date,
      status: :active
    )
  end

  def handle_successful_loan(loan)
    ActiveRecord::Base.transaction do
      @book.borrowed!
      if reservation = find_member_reservation
        reservation.fulfill!
      end
    end
    success_result("Book successfully borrowed", loan)
  end

  def handle_successful_reservation(reservation)
    @book.reserved! if @book.available?
    success_result("Book successfully reserved", reservation)
  end

  def handle_book_return(book_loan)
    next_reservation = @book.reservations.active.order(created_at: :asc).first

    if next_reservation
      @book.reserved!
      # Optionally notify the next member that their reservation is ready
      notify_next_member(next_reservation)
    else
      @book.available!
    end
  end

  def max_loans_reached?
    @member.book_loans.active.count >= BookLoan::MAX_LOANS_PER_MEMBER
  end

  def max_reservations_reached?
    @member.reservations.active.count >= Reservation::MAX_RESERVATIONS_PER_MEMBER
  end

  def has_overdue_books?
    @member.book_loans.overdue.any?
  end

  def already_reserved?
    @member.reservations.active.exists?(book_id: @book.id)
  end

  def find_member_reservation
    @member.reservations.active.find_by(book: @book)
  end

  def notify_next_member(reservation)
    # TODO: Implement notification system
    # LoanMailer.reservation_ready(reservation).deliver_later
  end

  def success_result(message, data = nil)
    Result.new(success: true, message: message, data: data)
  end

  def error_result(message)
    Result.new(success: false, message: message)
  end
end
