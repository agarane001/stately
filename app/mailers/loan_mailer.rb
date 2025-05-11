class LoanMailer < ApplicationMailer
  def due_date_reminder(loan)
    @loan = loan
    @member = loan.member
    @book = loan.book
    @days_until_due = (loan.due_date - Date.current).to_i

    mail(
      to: @member.email,
      subject: "Reminder: '#{@book.title}' is due in #{@days_until_due} days"
    )
  end

  def overdue_notice(loan)
    @loan = loan
    @member = loan.member
    @book = loan.book
    @days_overdue = loan.days_overdue

    mail(
      to: @member.email,
      subject: "Overdue Notice: '#{@book.title}' was due #{@days_overdue} days ago"
    )
  end
end
