class DashboardController < ApplicationController
  def index
    # Basic statistics
    @total_books = policy_scope(Book).count
    @total_members = policy_scope(Member).count
    @books_on_loan = policy_scope(BookLoan).active.count
    @active_reservations = policy_scope(Reservation).active.count

    # Recent activities
    @recent_loans = policy_scope(BookLoan).includes(:book, :member)
                                         .order(borrowed_date: :desc)
                                         .limit(5)

    @overdue_loans = policy_scope(BookLoan).includes(:book, :member)
                                          .overdue
                                          .order(due_date: :asc)
                                          .limit(5)

    @recent_reservations = policy_scope(Reservation).includes(:book, :member)
                                                  .where(status: [ :active, :fulfilled ])
                                                  .order(reserved_on: :desc)
                                                  .limit(5)
  end
end
