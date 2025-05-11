class BookLoan < ApplicationRecord
  belongs_to :book
  belongs_to :member

  enum :status, {
    active: 0,
    returned: 1,
    overdue: 2
  }

  validates :book_id, presence: true
  validates :member_id, presence: true
  validates :borrowed_date, presence: true
  validates :due_date, presence: true
  validate :due_date_must_be_after_borrowed_date
  validate :book_must_be_available, on: :create
  validate :member_can_borrow, on: :create

  scope :active, -> { where(status: :active) }
  scope :overdue, -> { active.where("due_date < ?", Date.current) }
  scope :recent, -> { order(created_at: :desc).limit(10) }

  after_create :mark_book_as_borrowed
  after_update :handle_return, if: :returned?

  LOAN_DURATION = 14.days
  MAX_LOANS_PER_MEMBER = 5

  def overdue?
    active? && due_date < Date.current
  end

  def return!
    return false unless active?
    transaction do
      update!(status: :returned, returned_date: Date.current)
      book.update!(status: :available)
      if reservation = book.reservations.active.first
        reservation.fulfill!
      end
      true
    end
  end

  def extend_loan!(days = 7)
    return false unless active?
    update!(due_date: due_date + days)
  end

  def days_overdue
    return 0 unless overdue?
    (Date.current - due_date).to_i
  end

  private

  def due_date_must_be_after_borrowed_date
    return if borrowed_date.blank? || due_date.blank?

    if due_date < borrowed_date
      errors.add(:due_date, "must be after the borrowed date")
    end
  end

  def book_must_be_available
    return unless book

    unless book.available?
      errors.add(:book, "is not available for borrowing")
    end
  end

  def member_can_borrow
    return unless member

    active_loans_count = member.book_loans.active.count
    if active_loans_count >= MAX_LOANS_PER_MEMBER
      errors.add(:member, "has reached the maximum number of allowed loans (#{MAX_LOANS_PER_MEMBER})")
    end

    if member.book_loans.overdue.any?
      errors.add(:member, "has overdue books that need to be returned first")
    end
  end

  def mark_book_as_borrowed
    book.borrowed!
  end

  def handle_return
    if book.reservations.active.any?
      book.reserved!
    else
      book.available!
    end
  end
end
