class Reservation < ApplicationRecord
  belongs_to :book
  belongs_to :member

  validates :reserved_on, presence: true
  validates :expiry_date, presence: true
  validates :status, presence: true
  validate :expiry_date_must_be_after_reserved_on
  validate :member_must_be_active
  validate :book_must_be_available_or_borrowed, on: :create
  validate :member_reservation_limit_not_exceeded, on: :create
  validate :member_can_reserve, on: :create
  validate :book_can_be_reserved, on: :create

  enum :status, {
    active: 0,
    fulfilled: 1,
    expired: 2,
    cancelled: 3
  }

  scope :active, -> { where(status: :active) }
  scope :expired, -> { where("expiry_date < ? AND status = ?", Date.current, statuses[:active]) }
  scope :pending, -> { where(status: [ :active, :expired ]) }
  scope :recent, -> { order(created_at: :desc).limit(10) }

  after_create :schedule_expiration
  after_update :notify_member_if_fulfilled

  RESERVATION_DURATION = 7.days
  MAX_RESERVATIONS_PER_MEMBER = 3

  def expired?
    active? && expiry_date < Date.current
  end

  def expire!
    return unless active?
    update!(status: :expired)
  end

  def fulfill!
    return unless active?
    update!(status: :fulfilled)
  end

  def cancel!
    return unless active?
    update!(status: :cancelled)
  end

  private

  def expiry_date_must_be_after_reserved_on
    return unless reserved_on && expiry_date
    if expiry_date <= reserved_on
      errors.add(:expiry_date, "must be after reservation date")
    end
  end

  def member_must_be_active
    return unless member
    unless member.active?
      errors.add(:member, "must be active to reserve books")
    end
  end

  def book_must_be_available_or_borrowed
    return unless book
    unless book.available? || book.borrowed?
      errors.add(:book, "cannot be reserved at this time")
    end
  end

  def member_reservation_limit_not_exceeded
    return unless member
    current_reservations = member.reservations.active.count
    if current_reservations >= MAX_RESERVATIONS_PER_MEMBER
      errors.add(:member, "has reached the maximum number of reservations (#{MAX_RESERVATIONS_PER_MEMBER})")
    end
  end

  def member_can_reserve
    if member.present?
      active_reservations = member.reservations.active.count
      if active_reservations >= 3
        errors.add(:member, "has reached the maximum number of active reservations")
      end
    end
  end

  def book_can_be_reserved
    if book.present?
      unless book.available_for_reservation?
        errors.add(:book, "cannot be reserved at this time")
      end
    end
  end

  def schedule_expiration
    ExpireReservationsJob.set(wait_until: expiry_date.to_datetime).perform_later(id)
  end

  def notify_member_if_fulfilled
    if saved_change_to_status? && fulfilled?
      # TODO: Send notification to member that their reservation is ready
    end
  end
end
