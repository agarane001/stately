class CreateReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :reservations do |t|
      t.references :book, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true
      t.date :reserved_on, null: false
      t.date :expiry_date, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :reservations, :status
    add_index :reservations, :reserved_on
    add_index :reservations, :expiry_date
  end
end
