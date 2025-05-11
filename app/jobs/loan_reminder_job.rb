class LoanReminderJob < ApplicationJob
  queue_as :default

  def perform
    # Find loans due in the next 3 days
    upcoming_due_loans = BookLoan.current
      .where("due_date BETWEEN ? AND ?", Date.current, 3.days.from_now)
      .includes(:member, :book)

    upcoming_due_loans.find_each do |loan|
      LoanMailer.due_date_reminder(loan).deliver_later
    end

    # Find overdue loans
    overdue_loans = BookLoan.overdue.includes(:member, :book)

    overdue_loans.find_each do |loan|
      LoanMailer.overdue_notice(loan).deliver_later
    end
  end
end
