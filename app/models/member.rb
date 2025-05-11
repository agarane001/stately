class Member < ApplicationRecord
  has_many :book_loans
  has_many :reservations
  has_many :borrowed_books, through: :book_loans, source: :book
  has_many :reserved_books, through: :reservations, source: :book

  enum :status, { active: 0, suspended: 1, expired: 2 }

  validates :name, presence: true, length: { maximum: 255 }
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :member_number, presence: true, uniqueness: true
  validates :phone, presence: true
  validates :status, presence: true

  scope :active, -> { where(status: :active) }
  scope :with_overdue_books, -> {
    joins(:book_loans)
      .where("book_loans.due_date < ? AND book_loans.returned_date IS NULL", Date.current)
      .distinct
  }

  def current_loans
    book_loans.where(returned_date: nil)
  end

  def overdue_loans
    current_loans.where("due_date < ?", Date.current)
  end

  def active_reservations
    reservations.where(status: :active)
  end
end
