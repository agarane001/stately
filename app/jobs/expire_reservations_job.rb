class ExpireReservationsJob < ApplicationJob
  queue_as :default

  def perform
    Reservation.expired.find_each do |reservation|
      reservation.update(status: :expired)

      # If the book was reserved and this was the only active reservation,
      # mark it as available
      if reservation.book.reserved? && !reservation.book.reservations.active.exists?
        reservation.book.available!
      end
    end
  end
end
