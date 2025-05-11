class Book < ApplicationRecord
  belongs_to :author
  belongs_to :category
  has_many :book_loans
  has_many :reservations
  has_many :borrowers, through: :book_loans, source: :member

  enum :status, {
    available: 0,
    borrowed: 1,
    reserved: 2,
    maintenance: 3
  }

  validates :title, presence: true, length: { maximum: 255 }
  validates :isbn, presence: true, uniqueness: true, length: { maximum: 13 }
  validates :published_date, presence: true
  validates :status, presence: true
  validate :published_date_cannot_be_in_future

  scope :available, -> { where(status: :available) }
  scope :borrowed, -> { where(status: :borrowed) }
  scope :reserved, -> { where(status: :reserved) }

  def available_for_reservation?
    available? || borrowed?
  end

  def current_loan
    book_loans.active.first
  end

  def active_reservation
    reservations.active.first
  end

  def can_be_borrowed?
    available? && !active_reservation
  end

  def can_be_reserved?
    (available? || borrowed?) && !active_reservation
  end

  private

  def published_date_cannot_be_in_future
    if published_date.present? && published_date > Date.current
      errors.add(:published_date, "can't be in the future")
    end
  end
end
